defmodule Apientry.DbCacheSupervisor do
  @moduledoc """
  Supervisor of DbCache instances.
  """

  import Supervisor.Spec
  import Ecto.Query, only: [from: 2]

  alias Apientry.Repo
  alias Apientry.Feed
  alias Apientry.Publisher
  alias Apientry.TrackingId

  def start_link(opts \\ []) do
    children = [
      worker(DbCache, [[
        name: :feed,
        repo: Repo,
        query: from(f in Feed, where: f.is_active == true),
        indices: [
          type_country_mobile: &({&1.feed_type, &1.country_code, &1.is_mobile})
        ]]], id: :feed),
      worker(DbCache, [[
        name: :publisher,
        repo: Repo,
        query: Publisher,
        indices: [
          api_key: &(&1.api_key)
        ]]], id: :publisher),
      worker(DbCache, [[
        name: :tracking_id,
        repo: Repo,
        query: TrackingId,
        indices: [
          publisher_code: &({&1.publisher_id, &1.code})
        ]]], id: :tracking_id)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: opts[:name])
  end

  @doc """
  Updates all database caches.

  Sends `DbCache.update/1` to all available workers.
  """
  def update do
    DbCache.update(:feed)
    DbCache.update(:publisher)
    DbCache.update(:tracking_id)
  end
end

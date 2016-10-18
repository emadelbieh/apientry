defmodule Apientry.DbCacheSupervisor do
  @moduledoc """
  Supervisor of DbCache instances.
  """

  import Supervisor.Spec

  alias Apientry.Repo
  alias Apientry.PublisherApiKey
  alias Apientry.EbayApiKey
  alias Apientry.TrackingId

  def start_link(opts \\ []) do
    children = [
      worker(DbCache, [[
        name: :ebay_api_key,
        repo: Repo,
        query: EbayApiKey,
        indices: [
          id: &(&1.id),
        ]]], id: :ebay_api_key),
      worker(DbCache, [[
        name: :publisher_api_key,
        repo: Repo,
        query: PublisherApiKey,
        indices: [
          value: &(&1.value)
        ]]], id: :publisher_api_key),
      worker(DbCache, [[
        name: :tracking_id,
        repo: Repo,
        query: TrackingId,
        indices: [
          publisher_code: &({&1.publisher_api_key_id, &1.code})
        ]]], id: :tracking_id)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: opts[:name])
  end

  @doc """
  Updates all database caches.

  Sends `DbCache.update/1` to all available workers.
  """
  def update do
    DbCache.update(:ebay_api_key)
    DbCache.update(:publisher_api_key)
    DbCache.update(:tracking_id)
  end
end

defmodule Apientry.DbCacheSupervisor do
  @moduledoc """
  Supervisor of DbCache instances.
  """

  import Supervisor.Spec

  alias Apientry.Repo
  alias Apientry.Publisher
  alias Apientry.PublisherApiKey
  alias Apientry.EbayApiKey
  alias Apientry.TrackingId
  alias Apientry.PublisherSubId
  alias Apientry.Blacklist

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
        name: :publisher,
        repo: Repo,
        query: Publisher,
        indices: [
          id: &(&1.id)
        ]]], id: :publisher),
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
        ]]], id: :tracking_id),
      worker(DbCache, [[
        name: :publisher_sub_id,
        repo: Repo,
        query: PublisherSubId,
        indices: [
          sub_id: &(&1.sub_id)
        ]]], id: :publisher_sub_id),
      worker(DbCache, [[
        name: :blacklist,
        repo: Repo,
        query: Blacklist,
        indices: [
          blacklist_type: &(&1.blacklist_type)
        ]]], id: :blacklist)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: opts[:name])
  end

  @doc """
  Updates all database caches.

  Sends `DbCache.update/1` to all available workers.
  """
  def update do
    DbCache.update(:ebay_api_key)
    DbCache.update(:publisher)
    DbCache.update(:publisher_api_key)
    DbCache.update(:tracking_id)
    DbCache.update(:publisher_sub_id)
    DbCache.update(:blacklist)
  end
end

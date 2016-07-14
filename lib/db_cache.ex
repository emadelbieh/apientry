defmodule DbCache do
  @moduledoc """
  Database caching.

      {:ok, pid} = DbCache.start_link(
        repo: Apientry.Repo,
        query: Apientry.Feed,
        indices: [
          country: &(&1.country),
          country_mobile: &({&1.country_code, &1.is_mobile})
        ])

      # Updates indices
      DbCache.fetch(pid)

      # Find one
      DbCache.lookup(pid, :country_mobile, {"US", true})

      # Find many
      DbCache.lookup_all(pid, :country, "US")
  """

  use GenServer

  @doc """
  Starts the GenServer. Returns `{:ok, pid}`.
  """
  def start_link(opts \\ []) do
    options = Enum.into(opts, %{})

    unless options[:repo] && options[:query] && options[:indices] do
      raise """
      Invalid options

      Required options: :repo, :query, :indices
      """
    end

    with {:ok, pid} <- GenServer.start_link(__MODULE__, options) do
      GenServer.call(pid, :init)
      {:ok, pid}
    end
  end

  @doc """
  Updates the indices based on database records.
  """
  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

  @doc """
  Looks up a record based on an index.

  Returns a single record, or `nil`.
  """
  def lookup(pid, index, value) do
    case lookup_all(pid, index, value) do
      [record] -> record
      [record | _] -> record
      [] -> nil
    end
  end

  @doc """
  Looks up many records based on an index.

  Returns a list of records.
  """
  def lookup_all(pid, index, value) do
    GenServer.call(pid, {:lookup_all, index, value})
  end

  @doc """
  Callback for GenServer.
  """
  def handle_call(:init, _, %{indices: indices} = state) do
    tables = Enum.reduce(indices, %{}, fn {index, _fun}, map ->
      table = :ets.new(:"db_cache_#{index}", [:bag])
      Map.put(map, index, table)
    end)

    state = state
    |> Map.put(:tables, tables)

    {:reply, :ok, state}
  end

  def handle_call(:debug, _, state) do
    {:reply, state, state}
  end

  def handle_call({:lookup_all, index, value}, _, %{tables: tables} = state) do
    table = tables[index]
    if table do
      results = :ets.lookup(table, value) # [{"12", %Model}, ...]
      objects = Enum.map(results, fn {_, obj} -> obj end)
      {:reply, objects, state}
    else
      {:reply, [], state}
    end
  end

  def handle_call(:fetch, _, %{repo: repo, query: query, tables: tables, indices: indices} = state) do
    results = repo.all(query)

    for {index, index_fun} <- indices do
      table = tables[index]
      :ets.delete_all_objects(table)
      for record <- results do
        key = index_fun.(record)
        :ets.insert(table, {key, record})
      end
    end

    {:reply, :ok, state}
  end
end

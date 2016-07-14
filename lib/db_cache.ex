defmodule DbCache do
  @moduledoc """
  Database caching.

      {:ok, pid} = DbCache.start_link(
        name: :feed,
        repo: Apientry.Repo,
        query: Apientry.Feed,
        indices: [
          country: &(&1.country),
          country_mobile: &({&1.country_code, &1.is_mobile})
        ])

      # Updates indices
      DbCache.update(:feed)

      # Find one
      DbCache.lookup(:feed, :country_mobile, {"US", true})

      # Find many
      DbCache.lookup_all(:feed, :country, "US")
  """

  use GenServer

  @doc """
  Starts the GenServer. Returns `{:ok, pid}`.
  """
  def start_link(opts \\ []) do
    options = Enum.into(opts, %{})

    unless options[:repo] && options[:query] && options[:indices] && options[:name] do
      raise """
      Invalid options

      Required options: :repo, :query, :indices, :name
      """
    end

    with {:ok, pid} <- GenServer.start_link(__MODULE__, options, name: options[:name]) do
      GenServer.call(pid, :init)
      GenServer.call(pid, :update)
      {:ok, pid}
    end
  end

  @doc """
  Updates the indices based on database records.
  """
  def update(pid) do
    GenServer.call(pid, :update)
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
  Stops a server.
  """
  def stop(pid, reason \\ :shutdown) do
    GenServer.stop(pid, reason)
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

  def handle_call(:update, _, %{repo: repo, query: query, tables: tables, indices: indices} = state) do
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

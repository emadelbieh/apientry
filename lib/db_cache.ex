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

    GenServer.start_link(__MODULE__, options, name: options[:name])
  end

  @doc """
  Updates the indices based on database records.
  """
  def update(pid) do
    GenServer.cast(pid, :update)
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
  Looks up many records based on an ndex.
  Returns a list of records.
  """
  def lookup_all(pid, index, value) do
    GenServer.call(pid, {:lookup_all, index, value})
  end

  @doc false
  def init(%{indices: indices} = state) do
    tables = Enum.reduce(indices, %{}, fn {index, _fun}, map ->
      table = :ets.new(:"db_cache_#{index}", [:bag])
      Map.put(map, index, table)
    end)

    state =
      state
      |> Map.put(:tables, tables)

    {:ok, do_update(state)}
  end

  def handle_call(:debug, _, state) do
    {:reply, state, state}
  end

  def handle_call({:lookup_all, index, value}, _, %{tables: tables} = state) do
    table = tables[index]

    objects =
      if table do
        results = :ets.lookup(table, value) # [{"12", %Model}, ...]
        Enum.map(results, fn {_, obj} -> obj end)
      else
        []
      end

    {:reply, objects, state}
  end

  def handle_cast(:update, state) do
    state = do_update(state)
    {:noreply, state}
  end

  defp do_update(%{repo: repo, query: query, tables: tables, indices: indices} = state) do
    results = repo.all(query)

    for {index, _} <- indices do
      table = tables[index]
      :ets.delete_all_objects(table)
    end

    for {index, index_fun} <- indices, record <- results do
      table = tables[index]
      key = index_fun.(record)
      :ets.insert(table, {key, record})
    end

    state
  end
end

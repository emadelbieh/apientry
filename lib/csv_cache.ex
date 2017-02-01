defmodule CsvCache do
  @doc """
  Starts a new cache
  """
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `cache` by `key`.
  """
  def get(cache, key) do
    Agent.get(cache, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key`, in the `cache`.
  """
  def put(cache, key, value) do
    Agent.update(cache, &Map.put(&1, key, value))
  end
end

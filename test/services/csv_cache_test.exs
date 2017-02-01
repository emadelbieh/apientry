defmodule CsvCacheTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, cache} = CsvCache.start_link
    {:ok, cache: cache}
  end

  test "stores value by key", %{cache: cache} do
    assert CsvCache.get(cache, "test") == nil

    CsvCache.put(cache, "test", ~r/test/)
    assert CsvCache.get(cache, "test") == ~r/test/
  end
end

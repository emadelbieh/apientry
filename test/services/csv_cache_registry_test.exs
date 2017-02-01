defmodule CsvCacheRegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, registry} = CsvCacheRegistry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns csv caches", %{registry: registry} do
    assert CsvCacheRegistry.lookup(registry, "us") == :error

    CsvCacheRegistry.create(registry, "us")
    assert {:ok, cache} = CsvCacheRegistry.lookup(registry, "us")

    CsvCache.put(cache, "test", ~r/test/)
    assert CsvCache.get(cache, "test") == ~r/test/
  end

  test "removes caches on exit", %{registry: registry} do
    CsvCacheRegistry.create(registry, "us")
    {:ok, cache} = CsvCacheRegistry.lookup(registry, "us")
    Agent.stop(cache)
    assert CsvCacheRegistry.lookup(registry, "us") == :error
  end

  test "removes a cache on crash", %{registry: registry} do
    CsvCacheRegistry.create(registry, "us")
    {:ok, cache} = CsvCacheRegistry.lookup(registry, "us")

    # stop the cache with non-normal reason
    Process.exit(cache, :shutdown)

    ref = Process.monitor(cache)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert CsvCacheRegistry.lookup(registry, "us") == :error
  end
end

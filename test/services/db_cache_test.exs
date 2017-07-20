defmodule Apientry.DbCacheTest do
  use Apientry.ModelCase

  #alias Apientry.Repo
  #alias Apientry.Feed

  #@name :db_cache_feed

  #describe "database cache" do
  #  setup [:mock_feeds, :start_cache]

  #  test "lookup_all (feed type)" do
  #    result = DbCache.lookup_all(@name, :feed_type, "ebay")
  #    assert length(result) == 6
  #  end

  #  test "lookup_all (type country mobile)" do
  #    [result] = DbCache.lookup_all(@name, :type_country_mobile, {"ebay", "US", true})
  #    assert result.__struct__ == Feed
  #    assert result.feed_type == "ebay"
  #    assert result.country_code == "US"
  #    assert result.is_mobile == true
  #  end

  #  test "lookup_all (fail)" do
  #    result = DbCache.lookup_all(@name, :type_country_mobile, {:non, :existing, :record})
  #    assert result == []
  #  end

  #  test "lookup_all (non-existent index)" do
  #    result = DbCache.lookup_all(@name, :not_an_index, nil)
  #    assert result == []
  #  end

  #  test "lookup (type country mobile)" do
  #    result = DbCache.lookup(@name, :type_country_mobile, {"ebay", "US", true})
  #    assert result.__struct__ == Feed
  #    assert result.feed_type == "ebay"
  #    assert result.country_code == "US"
  #    assert result.is_mobile == true
  #  end

  #  test "lookup (fail)" do
  #    result = DbCache.lookup(@name, :type_country_mobile, {:non, :existing, :record})
  #    assert result == nil
  #  end
  #end

  #defp mock_feeds(_context) do
  #  Repo.insert!(%Feed{feed_type: "ebay", api_key: "us-d", is_active: true, is_mobile: false, country_code: "US"})
  #  Repo.insert!(%Feed{feed_type: "ebay", api_key: "us-m", is_active: true, is_mobile: true,  country_code: "US"})
  #  Repo.insert!(%Feed{feed_type: "ebay", api_key: "gb-d", is_active: true, is_mobile: false, country_code: "GB"})
  #  Repo.insert!(%Feed{feed_type: "ebay", api_key: "gb-m", is_active: true, is_mobile: true,  country_code: "GB"})
  #  Repo.insert!(%Feed{feed_type: "ebay", api_key: "au-d", is_active: true, is_mobile: false, country_code: "AU"})
  #  Repo.insert!(%Feed{feed_type: "ebay", api_key: "au-m", is_active: true, is_mobile: true,  country_code: "AU"})
  #  :ok
  #end

  #defp start_cache(_context) do
  #  {:ok, pid} = DbCache.start_link(
  #    name: @name,
  #    repo: Repo,
  #    query: Feed,
  #    indices: [
  #      feed_type: &(&1.feed_type),
  #      type_country_mobile: &({&1.feed_type, &1.country_code, &1.is_mobile})
  #    ])

  #  {:ok, pid: pid}
  #end
end

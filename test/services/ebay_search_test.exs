defmodule EbaySearchTest do
  use ExUnit.Case
  doctest EbaySearch

  test "keyword" do
    url = EbaySearch.search("html", keyword: "nikon")
    assert url =~ ~r[/publisher/3.0/json/GeneralSearch]
    assert url =~ ~r[keyword=nikon]
    assert url =~ ~r(apiKey=[a-z0-9\-]{36})
  end

  test "xml" do
    url = EbaySearch.search("xml", keyword: "nikon")
    assert url =~ ~r[/publisher/3.0/rest/GeneralSearch]
  end

  test "custom params" do
    url = EbaySearch.search("xml", keyword: "nikon", aaa: 1, bbb: 2)
    assert url =~ ~r[aaa=1]
    assert url =~ ~r[bbb=2]
  end
end

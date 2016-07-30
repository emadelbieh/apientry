defmodule EbaySearchTest do
  use ExUnit.Case
  doctest EbaySearch

  @default_endpoint "GeneralSearch"

  test "keyword" do
    url = EbaySearch.search("html", @default_endpoint, keyword: "nikon", apiKey: "aoeu")
    assert url =~ ~r[/publisher/3.0/json/GeneralSearch]
    assert url =~ ~r[keyword=nikon]
    assert url =~ ~r[apiKey=aoeu]
  end

  test "custom endpoint" do
    url = EbaySearch.search("xml", "CategoryTree", keyword: "nikon")
    assert url =~ ~r[/publisher/3.0/rest/CategoryTree]
  end

  test "xml" do
    url = EbaySearch.search("xml", @default_endpoint, keyword: "nikon")
    assert url =~ ~r[/publisher/3.0/rest/GeneralSearch]
  end

  test "custom params" do
    url = EbaySearch.search("xml", @default_endpoint, keyword: "nikon", aaa: 1, bbb: 2)
    assert url =~ ~r[aaa=1]
    assert url =~ ~r[bbb=2]
  end

  test "keyword lists" do
    url = EbaySearch.search("xml", @default_endpoint, keyword: "nikon")
    assert url ==
      "http://api.ebaycommercenetwork.com/publisher/3.0/rest/GeneralSearch"
      <> "?keyword=nikon"
  end

  test "maps (string keys)" do
    url = EbaySearch.search("xml", @default_endpoint, %{"keyword" => "nikon"})
    assert url ==
      "http://api.ebaycommercenetwork.com/publisher/3.0/rest/GeneralSearch"
      <> "?keyword=nikon"
  end

  test "maps (atom keys)" do
    url = EbaySearch.search("xml", @default_endpoint, %{keyword: "nikon"})
    assert url ==
      "http://api.ebaycommercenetwork.com/publisher/3.0/rest/GeneralSearch"
      <> "?keyword=nikon"
  end

  test "stringkeyword lists" do
    url = EbaySearch.search("xml", @default_endpoint, [{"keyword", "nikon"}])
    assert url ==
      "http://api.ebaycommercenetwork.com/publisher/3.0/rest/GeneralSearch"
      <> "?keyword=nikon"
  end

  test "duplicate keys" do
    url = EbaySearch.search("xml", @default_endpoint, keyword: "nikon", keyword: "camera")
    assert url ==
      "http://api.ebaycommercenetwork.com/publisher/3.0/rest/GeneralSearch"
      <> "?keyword=nikon"
      <> "&keyword=camera"
  end
end

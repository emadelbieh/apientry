defmodule EbaySearch do
  @moduledoc """
  Generates Ebay Search URLs.

      EbaySearch.search("html", keyword: "nikon")
      => "http://sandbox.api.ebay.../?keyword=nikon"

      iex> EbaySearch.search("html", keyword: "nikon")
      "http://sandbox.api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?apiKey=aa13ff97-9515-4db5-9a62-e8981b615d36&keyword=nikon&showOffersOnly=true&trackingId=8095719&visitorIPAddress=&visitorUserAgent="
  """

  @defaults %{
    # apiKey: "78b0db8a-0ee1-4939-a2f9-d3cd95ec0fcc",
    apiKey: "aa13ff97-9515-4db5-9a62-e8981b615d36",
    showOffersOnly: "true",
    visitorUserAgent: "",
    visitorIPAddress: "",
    trackingId: "8095719",
  }

  @doc """
  Generates Ebay Search URLs.
  Allowed options:

  - `keyword` - required
  - `format` (:json or :xml) - defaults to :json
  - `apiKey`
  - `visitorUserAgent`
  - `visitorIPAddress`
  - `trackingId`
  """
  def search(format, params) do
    params = Enum.into(params, %{})
    params = Map.delete(params, :apiKey) # can't override this!
    query_params = Map.merge(@defaults, params)

    search_base(format) <> "?" <> URI.encode_query(query_params)
  end

  def search_base("xml") do
    raw_search_base "rest"
  end

  def search_base(_) do
    raw_search_base "json"
  end

  defp raw_search_base(ebay_format) do
    "http://api.ebaycommercenetwork.com/publisher/3.0/#{ebay_format}/GeneralSearch"
  end
end

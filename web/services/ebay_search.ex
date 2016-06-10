defmodule EbaySearch do
  @moduledoc """
  Generates Ebay Search URLs.

      EbaySearch.search("html", keyword: "nikon")
      => "http://sandbox.api.ebay.../?keyword=nikon"
  """

  @search_base "http://sandbox.api.ebaycommercenetwork.com/publisher/3.0/rest/GeneralSearch"

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
    defaults = %{
      apiKey: "78b0db8a-0ee1-4939-a2f9-d3cd95ec0fcc",
      showOffersOnly: "true",
      visitorUserAgent: "",
      visitorIPAddress: "",
      trackingId: "7000610",
    }
    query_params = Enum.into(params, defaults)

    search_base(format) <> "?" <> URI.encode_query(query_params)
  end

  def search_base("xml") do
    raw_search_base "rest"
  end

  def search_base(_) do
    raw_search_base "json"
  end

  defp raw_search_base(ebay_format) do
    "http://sandbox.api.ebaycommercenetwork.com/publisher/3.0/#{ebay_format}/GeneralSearch"
  end
end

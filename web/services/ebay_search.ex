defmodule EbaySearch do
  @moduledoc """
  Generates Ebay Search URLs.

      EbaySearch.search("html", keyword: "nikon")
      => "http://sandbox.api.ebay.../?keyword=nikon"

      iex> EbaySearch.search("html", keyword: "nikon")
      "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?apiKey=aa13ff97-9515-4db5-9a62-e8981b615d36&keyword=nikon&showOffersOnly=true&trackingId=8095719&visitorIPAddress=&visitorUserAgent="
  """

  @defaults %{
    # apiKey: "aa13ff97-9515-4db5-9a62-e8981b615d36",
    "apiKey" => "",
    "keyword" => "",
    "showOffersOnly" => "true",
    "visitorUserAgent" => "",
    "visitorIPAddress" => ""
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

  Parameters are string keys, like Phoenix's `params`.
  """
  def search(format, params) do
    query_params = Enum.into(params, @defaults)

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

defmodule EbaySearch do
  @moduledoc """
  Generates Ebay Search URLs.

      EbaySearch.search("html", keyword: "nikon")
      => "http://sandbox.api.ebay.../?keyword=nikon"

      iex> EbaySearch.search("html", keyword: "nikon")
      "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?keyword=nikon"
  """

  @ebay_search_domain Application.get_env(:apientry, :ebay_search_domain)

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
    search_base(format) <> "?" <> URI.encode_query(params)
  end

  def search_base("xml") do
    raw_search_base "rest"
  end

  def search_base(_) do
    raw_search_base "json"
  end

  defp raw_search_base(ebay_format) do
    "#{@ebay_search_domain}/publisher/3.0/#{ebay_format}/GeneralSearch"
  end
end

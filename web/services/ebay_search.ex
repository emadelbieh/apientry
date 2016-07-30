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

  - `format` (:json or :xml) - defaults to :json
  - `params` - can be either a `Map`, a `Keyword` list, or a `StringKeyword` list (a keyword list with string keys).

  Parameters are string keys, like Phoenix's `params`.
  """
  def search(format, params) do
    search(format, "GeneralSearch", params)
  end

  def search(format, endpoint, params) do
    search_base(format, endpoint) <> "?" <> URI.encode_query(params)
  end

  defp search_base(format, endpoint) do
    case format do
      "xml" -> raw_search_base("rest", endpoint)
      _ -> raw_search_base("json", endpoint)
    end
  end

  defp raw_search_base(ebay_format, endpoint) do
    "#{@ebay_search_domain}/publisher/3.0/#{ebay_format}/#{endpoint}"
  end
end

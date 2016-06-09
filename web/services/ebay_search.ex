defmodule EbaySearch do
  @moduledoc """
  Generates Ebay Search URLs.

      EbaySearch.search(keyword: "nikon")
      => "http://sandbox.api.ebay.../?keyword=nikon"
  """

  @search_url "http://sandbox.api.ebaycommercenetwork.com/publisher/3.0/rest/GeneralSearch"

  @doc """
  Generates Ebay Search URLs.
  """
  def search(params) do
    query_params = %{
      apiKey: params[:apiKey] || "78b0db8a-0ee1-4939-a2f9-d3cd95ec0fcc",
      showOffersOnly: "true",
      visitorUserAgent: params[:visitorUserAgent] || "",
      visitorIPAddress: params[:visitorIPAddress] || "",
      trackingId: params[:trackingId] || "7000610",
      keyword: params[:keyword]
    }

    url = @search_url <> "?" <> URI.encode_query(query_params)
  end
end

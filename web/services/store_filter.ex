defmodule Apientry.StoreFilter do
  @moduledoc """
  Exposes two functions:
    matches? - for dealing with simple store names
    matches_id? - for dealing with store_ids, e.g. store_walmart_com

  Warning:
    what about shoppingshadow.com vs shopping.com, shopping will match shoppingshadow
  """
  def matches?("ebay.com", store_name) do
    domain_matches?("ebay.com", store_name) ||
    domain_matches?("shopping.com", store_name)
  end

  def matches?("shopping.com", store_name) do
    domain_matches?("ebay.com", store_name) ||
    domain_matches?("shopping.com", store_name)
  end

  def matches?(domain, store_name) do
    domain_matches?(domain, store_name)
  end

  defp domain_matches?(domain, store_name) do
    normalized = store_name
                  |> remove_special_characters
                  |> String.downcase

    normalized =~ domain_without_tld(domain)
  end

  @doc """
  store_id e.g.
    store_best_deal_buys
    store_adorama
    store_42photo
    store_newegg_com_4224234
    store_midway_usa

  if store_id starts with store_,
    check whether the domain is part of the store id
    e.g. is newegg_com part of store_newegg_com_4224234?
  """
  def matches_id?(domain, store_id) do
    if is_store?(store_id) do
      strip_underscore(store_id) =~ domain_without_tld(domain)
    else
      false
    end
  end

  defp domain_without_tld(domain) do
    split = String.downcase(domain) |> String.split(".")

    string = if length(split)==2 do
      hd(split)
    else
      hd(tl(split))
    end
  end

  def remove_special_characters(store_name) do
    store_name
    |> String.replace(~r/[^a-zA-Z0-9]/, "")
  end

  defp strip_underscore(store_id) do
    store_id |> String.replace("_", "")
  end

  # checks if the given attribute satisfies our convention for stores
  # i.e. attribute is prefixed with store_
  defp is_store?(attribute) do
    get_prefix(attribute) == "store"
  end

  # gets the prefix of the store_id
  # e.g.
  #   rokinon                 -> rokinon
  #   brand_nikon             -> brand
  #   store_best_deal_buys    -> store
  defp get_prefix(store_id) do
    store_id
    |> String.split("_")
    |> hd()
  end
end

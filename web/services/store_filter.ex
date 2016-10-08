defmodule Apientry.StoreFilter do
  @moduledoc """
  Exposes two functions:
    matches? - for dealing with simple store names
    matches_id? - for dealing with store_ids, e.g. store_walmart_com
  """

  def matches?(domain, store_name) do
    split = String.downcase(domain) |> String.split(".")

    string = if length(split)==2 do
      hd(split)
    else
      hd(tl(split))
    end

    String.downcase(store_name) =~ string
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
      store_id =~ to_underscore(domain)
    else
      false
    end
  end

  defp to_underscore(domain) do
    domain
    |> String.downcase
    |> String.replace(".", "_")
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

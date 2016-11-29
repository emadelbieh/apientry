defmodule Apientry.StringKeyword do
  @moduledoc """
  Just like Keyword lists, but uses string keys.

  In Apientry, weneed to support repeating keywords, hence the need for this.

  Most of this code is taken from Elixir's own `Keyword` module, only adapted
  to check using `is_binary/1` instead of `is_atom/1`.
  """

  def delete(keywords, key, value) when is_list(keywords) and is_binary(key) do
    :lists.filter(fn {k, v} -> k != key or v != value end, keywords)
  end

  def delete(keywords, key) when is_list(keywords) and is_binary(key) do
    :lists.filter(fn {k, _} -> k != key end, keywords)
  end

  def fetch(keywords, key) when is_list(keywords) and is_binary(key) do
    case :lists.keyfind(key, 1, keywords) do
      {^key, value} -> {:ok, value}
      false -> :error
    end
  end

  def put(keywords, key, value) when is_list(keywords) and is_binary(key) do
    [{key, value} | delete(keywords, key)]
  end

  def stringify_keys([{key, value} | rest]) do
    [{to_string(key), value} | stringify_keys(rest)]
  end

  def stringify_keys([]) do
    []
  end

  @doc """
  Turns a query string into a list of `{key, value}` tuples.

  Compare this with `Plug.Conn.Query.decode/1`, which returns a Map. This one supports repeating keywords.

      iex> Apientry.StringKeyword.from_query_string("domain=ebay.com&keyword=nikon%20camera")
      [{"domain", "ebay.com"}, {"keyword", "nikon camera"}]
  """
  def from_query_string(query_string) do
    query_string
    |> String.split("&")
    |> Enum.map(fn item ->
      case String.split(item, "=") do
        [key, value] -> {"#{URI.decode(key)}", URI.decode(value)}
        [key] -> {"#{URI.decode(key)}", true}
        _ -> nil
      end
    end)
  end
end

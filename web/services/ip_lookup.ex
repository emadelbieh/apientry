defmodule IpLookup do
  @moduledoc """
  Looks up a country via Geolix.

      iex> IpLookup.lookup "203.167.4.14"
      "PH"

  Invalid entries are handled.

      iex> IpLookup.lookup "203.167.4.999"
      nil
  """

  def lookup(nil) do
    nil
  end

  def lookup(ip) do
    case Geolix.lookup(ip) do
      %{country: result} -> result.country.iso_code
      _ -> nil
    end
  end
end

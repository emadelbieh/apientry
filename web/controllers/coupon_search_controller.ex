defmodule Apientry.CouponSearchController do
  use Apientry.Web, :controller

  alias Apientry.Coupon
  import Ecto.Query

  def search(conn, _) do
    assigns = conn.assigns
    assigns = Map.put(assigns, :redirect_base, "#{conn.scheme}://#{conn.host}:#{conn.port}/redirect/")
    conn = Map.put(conn, :assigns, assigns)

    country = conn.params["country"] || get_country(conn.params)
    params = Map.put(conn.params, "country", country)
    conn = Map.put(conn, :params, params)

    coupons = Coupon.by_params(conn)
    json conn, Coupon.to_map(coupons)
  end

  defp get_country(%{"visitorIPAddress" => ip}) do
    case IpLookup.lookup(ip) do
      nil -> {:error, :unknown_country, %{ip: ip}}
      country ->
        if country == "GB" do
          "UK"
        else
          country
        end
    end
  end

  defp get_country(_) do
    "US"
  end
end

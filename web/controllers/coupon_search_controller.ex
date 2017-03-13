defmodule Apientry.CouponSearchController do
  use Apientry.Web, :controller

  alias Apientry.Coupon
  import Ecto.Query

  def search(conn, _) do
    assigns = conn.assigns
    assigns = Map.put(assigns, :redirect_base, "#{conn.scheme}://#{conn.host}:#{conn.port}/redirect/")
    conn = Map.put(conn, :assigns, assigns)

    country = conn.params["country"] || get_country(conn)
    params = Map.put(conn.params, "country", country)
    conn = Map.put(conn, :params, params)

    coupons = Coupon.by_params(conn)
    json conn, Coupon.to_map(coupons)
  end

  def get_country(conn) do
    ip = Enum.into(conn.req_headers, %{})["cf-connecting-ip"]

    case IpLookup.lookup(ip) do
      nil -> "US"
      country ->
        if country == "GB" do
          "UK"
        else
          country
        end
    end
  end
end

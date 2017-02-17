defmodule Apientry.CouponSearchController do
  use Apientry.Web, :controller

  alias Apientry.Coupon
  import Ecto.Query

  def search(conn, _) do
    assigns = conn.assigns
    assigns = Map.put(assigns, :redirect_base, "#{conn.scheme}://#{conn.host}:#{conn.port}/redirect/")
    conn = Map.put(conn, :assigns, assigns)
    coupons = Coupon.by_params(conn)
    json conn, Coupon.to_map(coupons)
  end
end

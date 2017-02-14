defmodule Apientry.CouponSearchController do
  use Apientry.Web, :controller

  alias Apientry.Coupon
  import Ecto.Query

  def search(conn, %{"domain" => domain} = params) do
    coupons = Repo.all(from c in Coupon, where: c.domain == ^domain)
    coupons = Coupon.track(coupons)
    json conn, Coupon.to_map(coupons)
  end

end

defmodule Apientry.CouponSearchControllerTest do
  use Apientry.ConnCase, async: true

  alias Apientry.Coupon

  @apientry %{id: "1", category: "some content", code: "some content", country: "some content", dealtype: "some content", domain: "apientry.com", enddate: "some content", holiday: "some content", lastmodified: "some content", logo: "some content", merchant: "some content", merchantid: "some content", network: "some content", offer: "some content", rating: "some content", restriction: "some content", startdate: "some content", url: "some content", website: "some content"}
  @apientry_with_category %{id: "2", category: "gift", code: "some content", country: "some content", dealtype: "some content", domain: "apientry.com", enddate: "some content", holiday: "some content", lastmodified: "some content", logo: "some content", merchant: "some content", merchantid: "some content", network: "some content", offer: "some content", rating: "some content", restriction: "some content", startdate: "some content", url: "some content", website: "some content"}
  @apientry_with_holiday %{id: "3", category: "some content", code: "some content", country: "some content", dealtype: "some content", domain: "apientry.com", enddate: "some content", holiday: "valentinesday", lastmodified: "some content", logo: "some content", merchant: "some content", merchantid: "some content", network: "some content", offer: "some content", rating: "some content", restriction: "some content", startdate: "some content", url: "some content", website: "some content"}
  @apientry_with_network %{id: "4", category: "some content", code: "some content", country: "some content", dealtype: "some content", domain: "apientry.com", enddate: "some content", holiday: "some content", lastmodified: "some content", logo: "some content", merchant: "some content", merchantid: "some content", network: "cj", offer: "some content", rating: "some content", restriction: "some content", startdate: "some content", url: "some content", website: "some content"}
  @apientry_with_dealtype %{id: "5", category: "some content", code: "some content", country: "some content", dealtype: "coupon", domain: "apientry.com", enddate: "some content", holiday: "some content", lastmodified: "some content", logo: "some content", merchant: "some content", merchantid: "some content", network: "some content", offer: "some content", rating: "some content", restriction: "some content", startdate: "some content", url: "some content", website: "some content"}
  @another %{id: "6", category: "some content", code: "some content", country: "some content", dealtype: "some content", domain: "another.com", enddate: "some content", holiday: "some content", lastmodified: "some content", logo: "some content", merchant: "some content", merchantid: "some content", network: "some content", offer: "some content", rating: "some content", restriction: "some content", startdate: "some content", url: "some content", website: "some content"}


  setup do
    changeset = Coupon.changeset(%Coupon{}, @apientry)
    {:ok, coupon} = Repo.insert(changeset)

    changeset = Coupon.changeset(%Coupon{}, @apientry_with_category)
    {:ok, coupon} = Repo.insert(changeset)

    changeset = Coupon.changeset(%Coupon{}, @apientry_with_holiday)
    {:ok, coupon} = Repo.insert(changeset)

    changeset = Coupon.changeset(%Coupon{}, @apientry_with_network)
    {:ok, coupon} = Repo.insert(changeset)

    changeset = Coupon.changeset(%Coupon{}, @apientry_with_dealtype)
    {:ok, coupon} = Repo.insert(changeset)

    changeset = Coupon.changeset(%Coupon{}, @another)
    {:ok, coupon} = Repo.insert(changeset)

    %{}
  end

  test "urls are in redirect format", %{conn: conn} do
    conn = get conn, coupon_search_path(conn, :search, domain: "apientry.com")
    json = hd(json_response(conn, 200))
    assert json["url"] =~ ~r/redirect/
  end

  test "list entries by domain name", %{conn: conn} do
    conn = get conn, coupon_search_path(conn, :search, domain: "apientry.com")
    coupons = json_response(conn, 200)
    assert Enum.count(coupons) == 5
    assert hd(coupons)["domain"] == "apientry.com"
  end

  test "list entries by domain name and category", %{conn: conn} do
    conn = get conn, coupon_search_path(conn, :search, domain: "apientry.com", category: "gift")
    coupons = json_response(conn, 200)
    assert Enum.count(coupons) == 1
    assert hd(coupons)["category"] == "gift"
  end

  test "list entries by domain name and holiday", %{conn: conn} do
    conn = get conn, coupon_search_path(conn, :search, domain: "apientry.com", holiday: "valentinesday")
    coupons = json_response(conn, 200)
    assert Enum.count(coupons) == 1
    assert hd(coupons)["holiday"] == "valentinesday"
  end

  test "list entries by domain name and network", %{conn: conn} do
    conn = get conn, coupon_search_path(conn, :search, domain: "apientry.com", network: "cj")
    coupons = json_response(conn, 200)
    assert Enum.count(coupons) == 1
    assert hd(coupons)["network"] == "cj"
  end

  test "list entries by domain name and dealtype", %{conn: conn} do
    conn = get conn, coupon_search_path(conn, :search, domain: "apientry.com", dealtype: "coupon")
    coupons = json_response(conn, 200)
    assert Enum.count(coupons) == 1
    assert hd(coupons)["dealtype"] == "coupon"
  end
end

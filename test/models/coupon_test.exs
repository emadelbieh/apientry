defmodule Apientry.CouponTest do
  use Apientry.ModelCase

  alias Apientry.Coupon

  @valid_attrs %{id: "1234", category: "some content", code: "some content", country: "some content", dealtype: "some content", domain: "some content", enddate: "some content", holiday: "some content", lastmodified: "some content", logo: "some content", merchant: "some content", merchantid: "some content", network: "some content", offer: "some content", rating: "some content", restriction: "some content", startdate: "some content", url: "some content", website: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Coupon.changeset(%Coupon{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Coupon.changeset(%Coupon{}, @invalid_attrs)
    refute changeset.valid?
  end
end

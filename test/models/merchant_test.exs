defmodule Apientry.MerchantTest do
  use Apientry.ModelCase

  alias Apientry.Merchant

  @valid_attrs %{country: "some content", domain: "some content", feeds4_id: "some content", logo: "some content", merchant: "some content", network: "some content", slug: "some content", url: "some content", website: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Merchant.changeset(%Merchant{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Merchant.changeset(%Merchant{}, @invalid_attrs)
    refute changeset.valid?
  end
end

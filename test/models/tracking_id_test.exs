defmodule Apientry.TrackingIdTest do
  use Apientry.ModelCase

  alias Apientry.TrackingId

  @valid_attrs %{subplacement: "Blackswan01", code: "12345678", ebay_api_key_id: 999}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TrackingId.changeset(%TrackingId{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TrackingId.changeset(%TrackingId{}, @invalid_attrs)
    refute changeset.valid?
  end
end

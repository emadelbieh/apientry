defmodule Apientry.TrackingIdTest do
  use Apientry.ModelCase

  alias Apientry.TrackingId

  @valid_attrs %{code: "some content", publisher_id: 999}
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

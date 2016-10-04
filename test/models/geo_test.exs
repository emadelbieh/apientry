defmodule Apientry.GeoTest do
  use Apientry.ModelCase

  alias Apientry.Geo

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Geo.changeset(%Geo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Geo.changeset(%Geo{}, @invalid_attrs)
    refute changeset.valid?
  end
end

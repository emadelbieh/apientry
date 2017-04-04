defmodule Apientry.BlacklistTest do
  use Apientry.ModelCase

  alias Apientry.Blacklist

  @valid_attrs %{blacklist_type: "some content", value: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Blacklist.changeset(%Blacklist{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Blacklist.changeset(%Blacklist{}, @invalid_attrs)
    refute changeset.valid?
  end
end

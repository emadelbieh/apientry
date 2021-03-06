defmodule Apientry.PublisherTest do
  use Apientry.ModelCase

  alias Apientry.Publisher

  @valid_attrs %{name: "Test Publisher"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Publisher.changeset(%Publisher{}, @valid_attrs)
    assert changeset.valid?
    refute changeset.changes.api_key == nil
  end

  test "changeset with invalid attributes" do
    changeset = Publisher.changeset(%Publisher{}, @invalid_attrs)
    refute changeset.valid?
  end
end

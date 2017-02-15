defmodule Apientry.PublisherSubIdTest do
  use Apientry.ModelCase

  alias Apientry.PublisherSubId

  @valid_attrs %{sub_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PublisherSubId.changeset(%PublisherSubId{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PublisherSubId.changeset(%PublisherSubId{}, @invalid_attrs)
    refute changeset.valid?
  end
end

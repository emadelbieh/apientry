defmodule Apientry.PublisherTest do
  use Apientry.ModelCase

  alias Apientry.Publisher

  @valid_attrs %{api_key: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Publisher.changeset(%Publisher{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Publisher.changeset(%Publisher{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule Apientry.PublisherApiKeyTest do
  use Apientry.ModelCase

  alias Apientry.PublisherApiKey

  @valid_attrs %{value: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PublisherApiKey.changeset(%PublisherApiKey{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PublisherApiKey.changeset(%PublisherApiKey{}, @invalid_attrs)
    refute changeset.valid?
  end
end

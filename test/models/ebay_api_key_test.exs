defmodule Apientry.EbayApiKeyTest do
  use Apientry.ModelCase

  alias Apientry.EbayApiKey

  @valid_attrs %{value: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EbayApiKey.changeset(%EbayApiKey{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EbayApiKey.changeset(%EbayApiKey{}, @invalid_attrs)
    refute changeset.valid?
  end
end

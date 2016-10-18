defmodule Apientry.EbayApiKeyTest do
  use Apientry.ModelCase

  alias Apientry.EbayApiKey

  @valid_attrs %{title: "Key1", value: "12345", account_id: "12"}
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

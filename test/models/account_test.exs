defmodule Apientry.AccountTest do
  use Apientry.ModelCase

  alias Apientry.Account

  @valid_attrs %{account_number: "100123123", name: "some content", geo_id: "12"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Account.changeset(%Account{}, @invalid_attrs)
    refute changeset.valid?
  end
end

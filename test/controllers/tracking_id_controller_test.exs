defmodule Apientry.TrackingIdControllerTest do
  use Apientry.ConnCase

  alias Apientry.Account
  alias Apientry.EbayApiKey
  alias Apientry.{TrackingId, Publisher}

  @valid_attrs %{code: "valid"}
  @invalid_attrs %{}

  setup do
    account = Repo.insert! %Account{name: "Blackswan 001"}
    ebay_api_key = Repo.insert! %EbayApiKey{value: "12345", account_id: account.id}
    publisher = Repo.insert! %Publisher{}
    user = insert_user()
    conn = assign(build_conn(), :current_user, user)

    {:ok, conn: conn, publisher: publisher, ebay_api_key: ebay_api_key, account: account}
  end

  test "renders form for new resources", %{conn: conn, account: account} do
    conn = get conn, tracking_id_path(conn, :new, account_id: account.id)
    assert html_response(conn, 200) =~ "New Tracking ID"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, ebay_api_key: ebay_api_key, account: account} do
    conn = post conn, tracking_id_path(conn, :create, account_id: account.id), tracking_id: %{subplacement: "Blackswan001", code: "valid", ebay_api_key_id: ebay_api_key.id}
    assert redirected_to(conn) == ebay_api_key_path(conn, :index, account_id: account.id)
    assert Repo.get_by(TrackingId, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, account: account} do
    conn = post conn, tracking_id_path(conn, :create, account_id: account.id), tracking_id: @invalid_attrs
    assert html_response(conn, 200) =~ "New Tracking ID"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, ebay_api_key: ebay_api_key, account: account} do
    tracking_id = Repo.insert! %TrackingId{ebay_api_key_id: ebay_api_key.id, code: "12345"}
    conn = put conn, tracking_id_path(conn, :update, tracking_id, account_id: account.id), tracking_id: %{code: ""}
    assert html_response(conn, 200) =~ "Modify tracking ID"
  end

  test "deletes chosen resource", %{conn: conn, ebay_api_key: ebay_api_key, account: account} do
    tracking_id = Repo.insert! %TrackingId{code: "delete me", ebay_api_key_id: ebay_api_key.id}
    conn = delete conn, tracking_id_path(conn, :delete, tracking_id, account_id: account.id)
    assert redirected_to(conn) == ebay_api_key_path(conn, :index, account_id: account.id)
    refute Repo.get(TrackingId, tracking_id.id)
  end
end

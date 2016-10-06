defmodule Apientry.EbayApiKeyControllerTest do
  use Apientry.ConnCase
  use Apientry.MockBasicAuth

  alias Apientry.Geo
  alias Apientry.Account
  alias Apientry.EbayApiKey

  @valid_attrs %{value: "some content"}
  @invalid_attrs %{}

  setup do
    geo = Repo.insert! %Geo{name: "US"}
    account = Repo.insert! %Account{geo_id: geo.id, name: "Blackswan 001"}
    {:ok, account: account}
  end

  test "lists all entries on index", %{conn: conn, account: account} do
    conn = get conn, ebay_api_key_path(conn, :index, account_id: account.id)
    assert html_response(conn, 200) =~ "API keys for #{account.name}"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, ebay_api_key_path(conn, :new)
    assert html_response(conn, 200) =~ "New ebay api key"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, account: account} do
    conn = post conn, ebay_api_key_path(conn, :create), ebay_api_key: %{value: "12345", account_id: account.id}
    assert redirected_to(conn) == ebay_api_key_path(conn, :index)
    assert Repo.get_by(EbayApiKey, %{value: "12345", account_id: account.id})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, ebay_api_key_path(conn, :create), ebay_api_key: @invalid_attrs
    assert html_response(conn, 200) =~ "New ebay api key"
  end

  test "shows chosen resource", %{conn: conn} do
    ebay_api_key = Repo.insert! %EbayApiKey{}
    conn = get conn, ebay_api_key_path(conn, :show, ebay_api_key)
    assert html_response(conn, 200) =~ "Show ebay api key"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, ebay_api_key_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    ebay_api_key = Repo.insert! %EbayApiKey{}
    conn = get conn, ebay_api_key_path(conn, :edit, ebay_api_key)
    assert html_response(conn, 200) =~ "Edit ebay api key"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, account: account} do
    ebay_api_key = Repo.insert! %EbayApiKey{}
    conn = put conn, ebay_api_key_path(conn, :update, ebay_api_key), ebay_api_key: %{value: "12345", account_id: account.id}
    assert redirected_to(conn) == ebay_api_key_path(conn, :show, ebay_api_key)
    assert Repo.get_by(EbayApiKey, %{value: "12345", account_id: account.id})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ebay_api_key = Repo.insert! %EbayApiKey{}
    conn = put conn, ebay_api_key_path(conn, :update, ebay_api_key), ebay_api_key: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit ebay api key"
  end

  test "deletes chosen resource", %{conn: conn} do
    ebay_api_key = Repo.insert! %EbayApiKey{}
    conn = delete conn, ebay_api_key_path(conn, :delete, ebay_api_key)
    assert redirected_to(conn) == ebay_api_key_path(conn, :index)
    refute Repo.get(EbayApiKey, ebay_api_key.id)
  end
end

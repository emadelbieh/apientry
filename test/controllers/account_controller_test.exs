defmodule Apientry.AccountControllerTest do
  use Apientry.ConnCase
  use Apientry.MockBasicAuth

  alias Apientry.Geo
  alias Apientry.Account

  @valid_attrs %{name: "BlackSwan Ebay 001"}
  @invalid_attrs %{}

  setup do
    geo = Repo.insert! %Geo{name: "US"}
    {:ok, geo: geo}
  end

  test "lists all entries on index", %{conn: conn, geo: geo} do
    conn = get conn, account_path(conn, :index, geo_id: geo.id)
    assert html_response(conn, 200) =~ "#{geo.name} Accounts"
  end

  test "renders form for new resources", %{conn: conn, geo: geo} do
    conn = get conn, account_path(conn, :new, geo_id: geo.id)
    assert html_response(conn, 200) =~ "New account"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, geo: geo} do
    conn = post conn, account_path(conn, :create), account: %{geo_id: geo.id, name: "Blackswan"}
    assert redirected_to(conn) == account_path(conn, :index, geo_id: geo.id)
    assert Repo.get_by(Account, %{geo_id: geo.id, name: "Blackswan"})
  end

  test "does not create resource with non-existent geo", %{conn: conn, geo: geo} do
    conn = post conn, account_path(conn, :create), account: %{geo_id: geo.id+1, name: "Blackswan"}
    assert html_response(conn, 200) =~ "errors"
  end

  test "does not create resource with duplicate name", %{conn: conn, geo: geo} do
    post conn, account_path(conn, :create), account: %{geo_id: geo.id, name: "Blackswan"}
    conn = post conn, account_path(conn, :create), account: %{geo_id: geo.id, name: "Blackswan"}
    assert html_response(conn, 200) =~ "error"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, account_path(conn, :create), account: @invalid_attrs
    assert html_response(conn, 200) =~ "New account"
  end

  test "shows chosen resource", %{conn: conn} do
    account = Repo.insert! %Account{}
    conn = get conn, account_path(conn, :show, account)
    assert html_response(conn, 200) =~ "Show account"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, account_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    account = Repo.insert! %Account{}
    conn = get conn, account_path(conn, :edit, account)
    assert html_response(conn, 200) =~ "Edit account"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, geo: geo} do
    account = Repo.insert! %Account{}
    conn = put conn, account_path(conn, :update, account), account: %{geo_id: geo.id, name: "Blackswan"}
    assert redirected_to(conn) == account_path(conn, :show, account)
    assert Repo.get_by(Account, %{geo_id: geo.id, name: "Blackswan"})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    account = Repo.insert! %Account{}
    conn = put conn, account_path(conn, :update, account), account: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit account"
  end

  test "deletes chosen resource", %{conn: conn} do
    account = Repo.insert! %Account{}
    conn = delete conn, account_path(conn, :delete, account)
    assert redirected_to(conn) == account_path(conn, :index)
    refute Repo.get(Account, account.id)
  end
end

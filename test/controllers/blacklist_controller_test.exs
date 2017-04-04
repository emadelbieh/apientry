defmodule Apientry.BlacklistControllerTest do
  use Apientry.ConnCase
  use Apientry.MockBasicAuth

  alias Apientry.Blacklist
  @valid_attrs %{blacklist_type: "some content", value: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, blacklist_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing blacklists"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, blacklist_path(conn, :new)
    assert html_response(conn, 200) =~ "New blacklist"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, blacklist_path(conn, :create), blacklist: @valid_attrs
    assert redirected_to(conn) == blacklist_path(conn, :index)
    assert Repo.get_by(Blacklist, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, blacklist_path(conn, :create), blacklist: @invalid_attrs
    assert html_response(conn, 200) =~ "New blacklist"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    blacklist = Repo.insert! %Blacklist{}
    conn = get conn, blacklist_path(conn, :edit, blacklist)
    assert html_response(conn, 200) =~ "Edit blacklist"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    blacklist = Repo.insert! %Blacklist{}
    conn = put conn, blacklist_path(conn, :update, blacklist), blacklist: @valid_attrs
    assert redirected_to(conn) == blacklist_path(conn, :show, blacklist)
    assert Repo.get_by(Blacklist, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    blacklist = Repo.insert! %Blacklist{}
    conn = put conn, blacklist_path(conn, :update, blacklist), blacklist: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit blacklist"
  end

  test "deletes chosen resource", %{conn: conn} do
    blacklist = Repo.insert! %Blacklist{}
    conn = delete conn, blacklist_path(conn, :delete, blacklist)
    assert redirected_to(conn) == blacklist_path(conn, :index)
    refute Repo.get(Blacklist, blacklist.id)
  end
end

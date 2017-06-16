defmodule Apientry.GeoControllerTest do
  use Apientry.ConnCase

  alias Apientry.Geo

  @valid_attrs %{name: "US"}
  @invalid_attrs %{}

  setup do
    user = insert_user()
    conn = assign(build_conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, geo_path(conn, :index)
    assert html_response(conn, 200) =~ "Available Geos"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, geo_path(conn, :new)
    assert html_response(conn, 200) =~ "Add new"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, geo_path(conn, :create), geo: @valid_attrs
    assert redirected_to(conn) == geo_path(conn, :index)
    assert Repo.get_by(Geo, @valid_attrs)
  end

  test "does not create resource with duplicate name", %{conn: conn} do
    post conn, geo_path(conn, :create), geo: @valid_attrs
    conn = post conn, geo_path(conn, :create), geo: @valid_attrs
    assert html_response(conn, 200) =~ "taken"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, geo_path(conn, :create), geo: @invalid_attrs
    assert html_response(conn, 200) =~ "Add new"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    geo = Repo.insert! %Geo{}
    conn = get conn, geo_path(conn, :edit, geo)
    assert html_response(conn, 200) =~ "Edit geo"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    geo = Repo.insert! %Geo{}
    conn = put conn, geo_path(conn, :update, geo), geo: @valid_attrs
    assert redirected_to(conn) == geo_path(conn, :index)
    assert Repo.get_by(Geo, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    geo = Repo.insert! %Geo{}
    conn = put conn, geo_path(conn, :update, geo), geo: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit geo"
  end

  test "deletes chosen resource", %{conn: conn} do
    geo = Repo.insert! %Geo{}
    conn = delete conn, geo_path(conn, :delete, geo)
    assert redirected_to(conn) == geo_path(conn, :index)
    refute Repo.get(Geo, geo.id)
  end
end

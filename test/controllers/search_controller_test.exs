defmodule Apientry.SearchControllerTest do
  use Apientry.ConnCase

  alias Apientry.Search
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, search_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = get conn, search_path(conn, :show, search)
    assert json_response(conn, 200)["data"] == %{"id" => search.id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, search_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, search_path(conn, :create), search: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Search, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, search_path(conn, :create), search: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = put conn, search_path(conn, :update, search), search: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Search, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = put conn, search_path(conn, :update, search), search: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = delete conn, search_path(conn, :delete, search)
    assert response(conn, 204)
    refute Repo.get(Search, search.id)
  end
end

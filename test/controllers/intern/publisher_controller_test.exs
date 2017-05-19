defmodule Apientry.Intern.PublisherControllerTest do
  use Apientry.ConnCase

  alias Apientry.Publisher
  @valid_attrs %{name: "some content", revenue_share: "120.5"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, intern_publisher_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = get conn, intern_publisher_path(conn, :show, publisher)
    assert json_response(conn, 200)["data"] == %{"id" => publisher.id,
      "name" => publisher.name,
      "revenue_share" => publisher.revenue_share}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, intern_publisher_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, intern_publisher_path(conn, :create), publisher: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Publisher, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, intern_publisher_path(conn, :create), publisher: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = put conn, intern_publisher_path(conn, :update, publisher), publisher: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Publisher, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = put conn, intern_publisher_path(conn, :update, publisher), publisher: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = delete conn, intern_publisher_path(conn, :delete, publisher)
    assert response(conn, 204)
    refute Repo.get(Publisher, publisher.id)
  end
end

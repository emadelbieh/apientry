defmodule Apientry.PublisherControllerTest do
  use Apientry.ConnCase
  use Apientry.MockBasicAuth

  alias Apientry.Publisher
  @valid_attrs %{name: "Test Publisher"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, publisher_path(conn, :index)
    assert html_response(conn, 200) =~ "Publishers"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, publisher_path(conn, :new)
    assert html_response(conn, 200) =~ "New publisher"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, publisher_path(conn, :create), publisher: @valid_attrs
    assert redirected_to(conn) == publisher_path(conn, :index)
    assert Repo.get_by(Publisher, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, publisher_path(conn, :create), publisher: @invalid_attrs
    assert html_response(conn, 200) =~ "New publisher"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, publisher_path(conn, :edit, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = get conn, publisher_path(conn, :edit, publisher)
    assert html_response(conn, 200) =~ "Edit publisher"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = put conn, publisher_path(conn, :update, publisher), publisher: @valid_attrs
    assert redirected_to(conn) == publisher_path(conn, :index)
    assert Repo.get_by(Publisher, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = put conn, publisher_path(conn, :update, publisher), publisher: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit publisher"
  end

  test "deletes chosen resource", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = delete conn, publisher_path(conn, :delete, publisher)
    assert redirected_to(conn) == publisher_path(conn, :index)
    refute Repo.get(Publisher, publisher.id)
  end

  test "api key regeneration", %{conn: conn} do
    publisher = Repo.insert! %Publisher{name: "Test Publisher", api_key: "testkey"}
    conn = put conn, publisher_path(conn, :regenerate, publisher)
    assert redirected_to(conn) == publisher_path(conn, :index)
    refute Repo.get_by(Publisher, api_key: "testkey")
  end
end

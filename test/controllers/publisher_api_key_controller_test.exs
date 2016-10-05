defmodule Apientry.PublisherApiKeyControllerTest do
  use Apientry.ConnCase
  use Apientry.MockBasicAuth

  alias Apientry.Publisher
  alias Apientry.PublisherApiKey
  @valid_attrs %{value: "12345"}
  @invalid_attrs %{}

  setup do
    publisher = Repo.insert! %Publisher{}
    {:ok, publisher: publisher}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, publisher_api_key_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing publisher api keys"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, publisher_api_key_path(conn, :new)
    assert html_response(conn, 200) =~ "New publisher api key"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, publisher: publisher} do
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{publisher_id: publisher.id, value: "12345"}
    assert redirected_to(conn) == publisher_api_key_path(conn, :index)
    assert Repo.get_by(PublisherApiKey, %{publisher_id: publisher.id, value: "12345"})
  end

  test "does not create resource when value already exists", %{conn: conn, publisher: publisher} do
    post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{publisher_id: publisher.id, value: "12345"}
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{publisher_id: publisher.id, value: "12345"}
    assert html_response(conn, 200) =~ "has already been taken"
  end

  test "does not create resource when publisher_id does not exist", %{conn: conn} do
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{value: "12345", publisher_id: "1"}
    assert html_response(conn, 200) =~ "check the errors"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: @invalid_attrs
    assert html_response(conn, 200) =~ "New publisher api key"
  end

  test "shows chosen resource", %{conn: conn} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = get conn, publisher_api_key_path(conn, :show, publisher_api_key)
    assert html_response(conn, 200) =~ "Show publisher api key"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, publisher_api_key_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = get conn, publisher_api_key_path(conn, :edit, publisher_api_key)
    assert html_response(conn, 200) =~ "Edit publisher api key"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, publisher: publisher} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = put conn, publisher_api_key_path(conn, :update, publisher_api_key), publisher_api_key: %{publisher_id: publisher.id, value: "12345"}
    assert redirected_to(conn) == publisher_api_key_path(conn, :show, publisher_api_key)
    assert Repo.get_by(PublisherApiKey, %{publisher_id: publisher.id, value: "12345"})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = put conn, publisher_api_key_path(conn, :update, publisher_api_key), publisher_api_key: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit publisher api key"
  end

  test "deletes chosen resource", %{conn: conn} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = delete conn, publisher_api_key_path(conn, :delete, publisher_api_key)
    assert redirected_to(conn) == publisher_api_key_path(conn, :index)
    refute Repo.get(PublisherApiKey, publisher_api_key.id)
  end
end

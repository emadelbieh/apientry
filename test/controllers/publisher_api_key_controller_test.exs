defmodule Apientry.PublisherApiKeyControllerTest do
  use Apientry.ConnCase

  alias Apientry.Publisher
  alias Apientry.PublisherApiKey
  @valid_attrs %{value: "12345"}
  @invalid_attrs %{}

  setup do
    user = insert_user()
    conn = assign(build_conn(), :current_user, user)
    publisher = Repo.insert! %Publisher{}
    {:ok, conn: conn, publisher: publisher}
  end

  test "lists all entries on index", %{conn: conn, publisher: publisher} do
    conn = get conn, publisher_api_key_path(conn, :index, publisher_id: publisher.id)
    assert html_response(conn, 200) =~ "Publisher API Keys"
  end

  test "renders form for new resources", %{conn: conn, publisher: publisher} do
    conn = get conn, publisher_api_key_path(conn, :new, publisher_id: publisher.id)
    assert html_response(conn, 200) =~ "New Publisher API Key"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, publisher: publisher} do
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{publisher_id: publisher.id, title: "Key 1", value: "12345"}
    assert redirected_to(conn) == publisher_api_key_path(conn, :index, publisher_id: publisher.id)
    assert Repo.get_by(PublisherApiKey, %{publisher_id: publisher.id, value: "12345", title: "Key 1"})
  end

  test "generates value if left blank", %{conn: conn, publisher: publisher} do
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{publisher_id: publisher.id, title: "Key 1", value: ""}
    assert redirected_to(conn) == publisher_api_key_path(conn, :index, publisher_id: publisher.id)
    publisher_api_key = Repo.get_by(PublisherApiKey, %{publisher_id: publisher.id, title: "Key 1"})
    assert publisher_api_key.value != nil
    assert publisher_api_key.value != ""
  end

  test "does not create resource when value already exists", %{conn: conn, publisher: publisher} do
    post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{publisher_id: publisher.id, title: "Key1", value: "12345"}
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{publisher_id: publisher.id, title: "Key2", value: "12345"}
    assert html_response(conn, 200) =~ "has already been taken"
  end

  test "does not create resource when publisher_id does not exist", %{conn: conn} do
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: %{value: "12345", publisher_id: "1"}
    assert html_response(conn, 200) =~ "check the errors"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, publisher_api_key_path(conn, :create), publisher_api_key: @invalid_attrs
    assert html_response(conn, 200) =~ "New Publisher API Key"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = get conn, publisher_api_key_path(conn, :edit, publisher_api_key)
    assert html_response(conn, 200) =~ "Edit publisher api key"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, publisher: publisher} do
    publisher_api_key = Repo.insert! PublisherApiKey.changeset(%PublisherApiKey{}, %{title: "Pub1", publisher_id: publisher.id, value: "12345"})
    conn = put conn, publisher_api_key_path(conn, :update, publisher_api_key, publisher_id: publisher.id), publisher_api_key: %{title: "Publisher1", publisher_id: publisher.id, value: "12345"}
    assert redirected_to(conn) == publisher_api_key_path(conn, :index)
    assert Repo.get_by(PublisherApiKey, %{publisher_id: publisher.id, value: "12345", title: "Publisher1"})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, publisher: publisher} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = put conn, publisher_api_key_path(conn, :update, publisher_api_key, publisher_id: publisher.id), publisher_api_key: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit publisher api key"
  end

  test "deletes chosen resource", %{conn: conn} do
    publisher_api_key = Repo.insert! %PublisherApiKey{}
    conn = delete conn, publisher_api_key_path(conn, :delete, publisher_api_key)
    assert redirected_to(conn) == publisher_api_key_path(conn, :index, publisher_id: publisher_api_key.publisher_id)
    refute Repo.get(PublisherApiKey, publisher_api_key.id)
  end
end

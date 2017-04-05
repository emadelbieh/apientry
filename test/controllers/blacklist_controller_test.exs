defmodule Apientry.BlacklistControllerTest do
  use Apientry.ConnCase
  use Apientry.MockBasicAuth

  alias Apientry.Blacklist
  @valid_attrs %{blacklist_type: "some content", value: "some content"}
  @invalid_attrs %{}

  alias Apientry.{Publisher, PublisherSubId}

  setup do
    publisher = Repo.insert!(Publisher.changeset(%Publisher{}, %{name: "test"}))
    publisher_sub_id = Repo.insert!(PublisherSubId.changeset(%PublisherSubId{}, %{sub_id: "001", publisher_id: publisher.id}))
    {:ok, publisher_sub_id: publisher_sub_id}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, blacklist_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing blacklists"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, blacklist_path(conn, :new)
    assert html_response(conn, 200) =~ "New blacklist"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, publisher_sub_id: publisher_sub_id} do
    blacklist_params = Map.merge(@valid_attrs, %{publisher_sub_id_id: publisher_sub_id.id})
    conn = post conn, blacklist_path(conn, :create), blacklist: blacklist_params
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

  test "updates chosen resource and redirects when data is valid", %{conn: conn, publisher_sub_id: publisher_sub_id} do
    blacklist = Repo.insert! %Blacklist{}
    blacklist_params = Map.merge(@valid_attrs, %{publisher_sub_id_id: publisher_sub_id.id})
    conn = put conn, blacklist_path(conn, :update, blacklist), blacklist: blacklist_params
    assert redirected_to(conn) == blacklist_path(conn, :index)
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

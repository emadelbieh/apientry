defmodule Apientry.PublisherSubIdControllerTest do
  use Apientry.ConnCase

  alias Apientry.PublisherSubId
  @valid_attrs %{sub_id: "some content"}
  @invalid_attrs %{}

  setup do
    user = insert_user()
    conn = assign(build_conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, publisher_sub_id_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing publisher sub ids"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, publisher_sub_id_path(conn, :new)
    assert html_response(conn, 200) =~ "New publisher sub id"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, publisher_sub_id_path(conn, :create), publisher_sub_id: @valid_attrs
    assert redirected_to(conn) == publisher_sub_id_path(conn, :index)
    assert Repo.get_by(PublisherSubId, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, publisher_sub_id_path(conn, :create), publisher_sub_id: @invalid_attrs
    assert html_response(conn, 200) =~ "New publisher sub id"
  end

  test "shows chosen resource", %{conn: conn} do
    publisher_sub_id = Repo.insert! %PublisherSubId{}
    conn = get conn, publisher_sub_id_path(conn, :show, publisher_sub_id)
    assert html_response(conn, 200) =~ "Show publisher sub id"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, publisher_sub_id_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    publisher_sub_id = Repo.insert! %PublisherSubId{}
    conn = get conn, publisher_sub_id_path(conn, :edit, publisher_sub_id)
    assert html_response(conn, 200) =~ "Edit publisher sub id"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    publisher_sub_id = Repo.insert! %PublisherSubId{}
    conn = put conn, publisher_sub_id_path(conn, :update, publisher_sub_id), publisher_sub_id: @valid_attrs
    assert redirected_to(conn) == publisher_sub_id_path(conn, :show, publisher_sub_id)
    assert Repo.get_by(PublisherSubId, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    publisher_sub_id = Repo.insert! %PublisherSubId{}
    conn = put conn, publisher_sub_id_path(conn, :update, publisher_sub_id), publisher_sub_id: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit publisher sub id"
  end

  test "deletes chosen resource", %{conn: conn} do
    publisher_sub_id = Repo.insert! %PublisherSubId{}
    conn = delete conn, publisher_sub_id_path(conn, :delete, publisher_sub_id)
    assert redirected_to(conn) == publisher_sub_id_path(conn, :index)
    refute Repo.get(PublisherSubId, publisher_sub_id.id)
  end
end

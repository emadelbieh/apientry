defmodule Apientry.TrackingIdControllerTest do
  use Apientry.ConnCase

  alias Apientry.{TrackingId, Publisher}
  @valid_attrs %{code: "valid"}
  @invalid_attrs %{}

  setup do
    publisher = Repo.insert! %Publisher{}
    {:ok, publisher: publisher}
  end

  test "renders form for new resources", %{conn: conn, publisher: publisher} do
    conn = get conn, publisher_tracking_id_path(conn, :new, publisher)
    assert html_response(conn, 200) =~ "New Tracking ID"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, publisher: publisher} do
    conn = post conn, publisher_tracking_id_path(conn, :create, publisher), tracking_id: @valid_attrs
    assert redirected_to(conn) == publisher_tracking_id_path(conn, :index, publisher)
    assert Repo.get_by(TrackingId, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, publisher: publisher} do
    conn = post conn, publisher_tracking_id_path(conn, :create, publisher), tracking_id: @invalid_attrs
    assert html_response(conn, 200) =~ "New Tracking ID"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, publisher: publisher} do
    assert_error_sent 404, fn ->
      get conn, publisher_tracking_id_path(conn, :edit, publisher, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, publisher: publisher} do
    tracking_id = Repo.insert! %TrackingId{}
    conn = get conn, publisher_tracking_id_path(conn, :edit, publisher, tracking_id)
    assert html_response(conn, 200) =~ "Edit"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, publisher: publisher} do
    tracking_id = Repo.insert! %TrackingId{code: "update me", publisher_id: publisher.id}
    conn = put conn, publisher_tracking_id_path(conn, :update, publisher, tracking_id), tracking_id: @valid_attrs
    assert redirected_to(conn) == publisher_tracking_id_path(conn, :index, publisher)
    assert Repo.get_by(TrackingId, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, publisher: publisher} do
    tracking_id = Repo.insert! %TrackingId{}
    conn = put conn, publisher_tracking_id_path(conn, :update, publisher, tracking_id), tracking_id: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit tracking id"
  end

  test "deletes chosen resource", %{conn: conn, publisher: publisher} do
    tracking_id = Repo.insert! %TrackingId{code: "delete me", publisher_id: publisher.id}
    conn = delete conn, publisher_tracking_id_path(conn, :delete, publisher, tracking_id)
    assert redirected_to(conn) == publisher_tracking_id_path(conn, :index, publisher)
    refute Repo.get(TrackingId, tracking_id.id)
  end
end

defmodule Apientry.FeedControllerTest do
  use Apientry.ConnCase

  alias Apientry.Feed
  use Apientry.MockBasicAuth

  @valid_attrs %{api_key: "some content", country_code: "some content", feed_type: "some content", is_active: true, is_mobile: true}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, feed_path(conn, :index)
    assert html_response(conn, 200) =~ "Feeds"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, feed_path(conn, :new)
    assert html_response(conn, 200) =~ "New feed"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, feed_path(conn, :create), feed: @valid_attrs
    assert redirected_to(conn) == feed_path(conn, :index)
    assert Repo.get_by(Feed, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, feed_path(conn, :create), feed: @invalid_attrs
    assert html_response(conn, 200) =~ "New feed"
  end

  test "shows chosen resource", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = get conn, feed_path(conn, :show, feed)
    assert html_response(conn, 200) =~ "#{feed.feed_type} - #{feed.country_code}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, feed_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = get conn, feed_path(conn, :edit, feed)
    assert html_response(conn, 200) =~ "Edit feed"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = put conn, feed_path(conn, :update, feed), feed: @valid_attrs
    assert redirected_to(conn) == feed_path(conn, :index)
    assert Repo.get_by(Feed, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = put conn, feed_path(conn, :update, feed), feed: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit feed"
  end

  test "deletes chosen resource", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = delete conn, feed_path(conn, :delete, feed)
    assert redirected_to(conn) == feed_path(conn, :index)
    refute Repo.get(Feed, feed.id)
  end
end

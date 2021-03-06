defmodule Apientry.RedirectControllerTest do
  use Apientry.ConnCase

  test "redirects", %{conn: conn} do
    conn = get conn, redirect_path(conn, :show, Base.url_encode64("?link=http://google.com&event=CLICK_OFFER_URL"))
    assert redirected_to(conn) == "http://google.com"
  end

  test "bad request (invalid event name)", %{conn: conn} do
    conn = get conn, redirect_path(conn, :show, Base.url_encode64("?link=http://google.com&event=xyz"))
    assert json_response(conn, 400)["error"] == "invalid_event"
  end

  test "bad request (no ?)", %{conn: conn} do
    conn = get conn, redirect_path(conn, :show, Base.url_encode64("hello"))
    assert json_response(conn, 400)["error"] == "invalid_format"
  end

  test "bad request (invalid qs)", %{conn: conn} do
    conn = get conn, redirect_path(conn, :show, Base.url_encode64("?%"))
    assert json_response(conn, 400)["error"] == "invalid_query_string"
  end

  test "bad request (not base64)", %{conn: conn} do
    conn = get conn, redirect_path(conn, :show, "not base 64")
    assert json_response(conn, 400)["error"] == "invalid_base64"
  end

  test "bad request (no ?link)", %{conn: conn} do
    conn = get conn, redirect_path(conn, :show, Base.url_encode64("?a=b"))
    assert json_response(conn, 400)["error"] == "no_link"
  end
end

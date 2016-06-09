defmodule Apientry.SearchControllerTest do
  use Apientry.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "legit requests", %{conn: conn} do
    conn = get conn(), search_path(conn, :search, keyword: "nikon")
    assert conn.status == 200
    assert conn.resp_body =~ "urn:types.partner.api.shopping.com"
  end

  test "bad requests", %{conn: conn} do
    conn = get conn(), search_path(conn, :search)
    body = json_response(conn, 500)
    assert "Invalid request" == body["message"]
  end
end

defmodule Apientry.SearchControllerTest do
  use Apientry.ConnCase
  require MockEbay

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "legit requests", %{conn: conn} do
    MockEbay.mock_ok do
      conn = get conn(), search_path(conn, :search, keyword: "nikon")
      assert conn.status == 200

      {_, content_type} = List.keyfind(conn.resp_headers, "content-type", 0)
      assert content_type == "text/xml; charset=utf-8"

      {_, allowed_origins} = List.keyfind(conn.resp_headers, "access-control-allow-origin", 0)
      assert allowed_origins == "*"

      assert conn.resp_body =~ "urn:types.partner.api.shopping.com"
    end
  end

  test "failing requests when eBay is down", %{conn: conn} do
    MockEbay.mock_fail do
      conn = get conn(), search_path(conn, :search, keyword: "nikon")
      body = json_response(conn, 500)
      assert "nxdomain" == body["message"]
    end
  end

  test "bad requests", %{conn: conn} do
    conn = get conn(), search_path(conn, :search)
    body = json_response(conn, 500)
    assert "Invalid request" == body["message"]
  end
end

defmodule Apientry.SearchControllerTest do
  use Apientry.ConnCase
  use MockEbay
  import List, only: [keyfind: 3]
  import Plug.Conn, only: [put_req_header: 3]

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "legit requests", %{conn: conn} do
    MockEbay.mock_ok do
      conn = get conn(), search_path(conn, :search, keyword: "nikon")
      assert conn.status == 200

      {_, content_type} = keyfind(conn.resp_headers, "content-type", 0)
      assert content_type == "text/xml; charset=utf-8"

      {_, allowed_origins} = keyfind(conn.resp_headers, "access-control-allow-origin", 0)
      assert allowed_origins == "*"

      assert conn.resp_body =~ "urn:types.partner.api.shopping.com"
    end
  end

  test "other params", %{conn: conn} do
    MockEbay.mock_ok do
      conn = get conn(), search_path(conn, :search, keyword: "nikon", xxx: "111")
      assert conn.status == 200
    end
  end

  test "options for cors", %{conn: conn} do
    conn = options conn(), search_path(conn, :search, keyword: "nikon")
    assert conn.status == 204 # no content

    {_, allowed_origins} = keyfind(conn.resp_headers, "access-control-allow-origin", 0)
    assert allowed_origins == "*"

    {_, allowed_methods} = keyfind(conn.resp_headers, "access-control-allow-methods", 0)
    assert allowed_methods == "GET,POST,PUT,PATCH,DELETE,OPTIONS"
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

  test "bad requests in XML", %{conn: conn} do
    conn = conn()
    |> put_req_header("accept", "text/xml")
    |> get(search_path(conn, :search))

    {_, content_type} = keyfind(conn.resp_headers, "content-type", 0)
    assert content_type == "text/xml; charset=utf-8"

    assert conn.status === 500
    assert conn.resp_body == ~s[<Error message="Invalid request"></Error>]
  end
end

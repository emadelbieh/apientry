defmodule Apientry.SearchControllerTest do
  use Apientry.ConnCase
  use MockEbay
  import List, only: [keyfind: 3]
  import Plug.Conn, only: [put_req_header: 3]
  alias Apientry.Fixtures

  setup %{conn: conn} do
    Fixtures.mock_feeds
    Fixtures.mock_publishers
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @valid_attrs [
    keyword: "nikon",
    apiKey: "panda-abc",
    visitorIPAddress: "8.8.8.8",
    visitorUserAgent: "Chrome"
  ]

  test "legit requests", %{conn: conn} do
    MockEbay.mock_ok do
      conn = get build_conn(), search_path(conn, :search, @valid_attrs)
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
      conn = get build_conn(), search_path(conn, :search, @valid_attrs ++ [xxx: 111])
      assert conn.status == 200
    end
  end

  test "options for cors", %{conn: conn} do
    conn = options build_conn(), search_path(conn, :search, @valid_attrs)
    assert conn.status == 204 # no content

    {_, allowed_origins} = keyfind(conn.resp_headers, "access-control-allow-origin", 0)
    assert allowed_origins == "*"

    {_, allowed_methods} = keyfind(conn.resp_headers, "access-control-allow-methods", 0)
    assert allowed_methods == "GET,POST,PUT,PATCH,DELETE,OPTIONS"
  end

  test "failing requests when eBay is down", %{conn: conn} do
    MockEbay.mock_fail do
      conn = get build_conn(), search_path(conn, :search, @valid_attrs)
      body = json_response(conn, 400)
      assert "nxdomain" == body["message"]
    end
  end

  test "bad requests", %{conn: conn} do
    conn = get build_conn(), search_path(conn, :search)
    body = json_response(conn, 400)
    assert "Invalid request" == body["message"]
  end

  test "bad requests in XML", %{conn: conn} do
    conn = build_conn()
    |> put_req_header("accept", "text/xml")
    |> get(search_path(conn, :search))

    {_, content_type} = keyfind(conn.resp_headers, "content-type", 0)
    assert content_type == "text/xml; charset=utf-8"

    assert conn.status === 400
    assert conn.resp_body == ~s[<Error message="Invalid request"></Error>]
  end

  test "dry run of a legit request", %{conn: conn} do
    conn = get build_conn(), search_path(conn, :dry_search,
     keyword: "nikon",
     apiKey: "panda-abc",
     visitorIPAddress: "8.8.8.8",
     visitorUserAgent: "Chrome")
    body = json_response(conn, 200)

    assert body["valid"] == true
    assert body["country"] == "US"
    assert body["format"] == "json"
    assert body["is_mobile"] == false
    assert body["url"] ==
      "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch"
      <> "?apiKey=us-d"
      <> "&keyword=nikon"
      <> "&showOffersOnly=true"
      <> "&visitorIPAddress=8.8.8.8"
      <> "&visitorUserAgent=Chrome"
  end

  test "dry run of an invalid request", %{conn: conn} do
    conn = get build_conn(), search_path(conn, :dry_search)
    body = json_response(conn, 200)

    assert body == %{"valid" => false}
  end
end

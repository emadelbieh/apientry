defmodule Apientry.SearchControllerTest do
  use Apientry.ConnCase, async: true
  use MockEbay
  import Plug.Conn, only: [put_req_header: 3]
  alias Apientry.Fixtures
  alias Apientry.DbCacheSupervisor

  setup %{conn: conn} do
    Fixtures.mock_feeds
    Fixtures.mock_publishers
    DbCacheSupervisor.update

    conn = conn
    |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  use Apientry.MockBasicAuth

  @valid_attrs [
    keyword: "nikon",
    apiKey: "panda-abc",
    visitorIPAddress: "8.8.8.8",
    visitorUserAgent: "Chrome",
    domain: "site.com"
  ]

  #@tag :capture_log
  #test "legit requests", %{conn: conn} do
  #  MockEbay.mock_ok do
  #    conn = get build_conn(), search_path(conn, :search, @valid_attrs)
  #    assert conn.status == 200

  #    {_, content_type} = keyfind(conn.resp_headers, "content-type", 0)
  #    assert content_type == "application/json; charset=utf-8"

  #    {_, allowed_origins} = keyfind(conn.resp_headers, "access-control-allow-origin", 0)
  #    assert allowed_origins == "*"

  #    assert conn.resp_body =~ "categories"
  #  end
  #end

  #@tag :capture_log
  #test "legit requests with repeating keys", %{conn: conn} do
  #  MockEbay.mock_ok do
  #    path = search_path(conn, :search, @valid_attrs)
  #    <> "&attributeValue=apple"
  #    <> "&attributeValue=banana"

  #    conn = get build_conn(), path
  #    assert conn.status == 200
  #  end
  #end

  #@tag :capture_log
  #test "other params", %{conn: conn} do
  #  MockEbay.mock_ok do
  #    conn = get build_conn(), search_path(conn, :search, @valid_attrs ++ [xxx: 111])
  #    assert conn.status == 200
  #  end
  #end

  #test "options for cors", %{conn: conn} do
  #  conn = options build_conn(), search_path(conn, :search, @valid_attrs)
  #  assert conn.status == 204 # no content

  #  {_, allowed_origins} = keyfind(conn.resp_headers, "access-control-allow-origin", 0)
  #  assert allowed_origins == "*"

  #  {_, allowed_methods} = keyfind(conn.resp_headers, "access-control-allow-methods", 0)
  #  assert allowed_methods == "GET,POST,PUT,PATCH,DELETE,OPTIONS"
  #end

  #test "failing requests when eBay is down", %{conn: conn} do
  #  MockEbay.mock_fail do
  #    conn = get build_conn(), search_path(conn, :search, @valid_attrs)
  #    body = json_response(conn, 400)
  #    assert "nxdomain" == body["error"]
  #  end
  #end

  #test "bad requests", %{conn: conn} do
  #  conn = get build_conn(), search_path(conn, :search)
  #  body = json_response(conn, 400)
  #  assert "missing_parameters" == body["error"]
  #  assert body["details"]["required"]
  #end

  #test "bad requests in XML", %{conn: conn} do
  #  conn = build_conn()
  #  |> put_req_header("accept", "text/xml")
  #  |> get(search_path(conn, :search))

  #  {_, content_type} = keyfind(conn.resp_headers, "content-type", 0)
  #  assert content_type == "text/xml; charset=utf-8"

  #  assert conn.status === 400
  #  assert conn.resp_body =~ ~r[<Error error="missing_parameters" />]
  #end

  #test "dry run of a legit request", %{conn: conn} do
  #  conn = get conn, search_path(conn, :dry_search, @valid_attrs)
  #  body = json_response(conn, 200)

  #  IEx.pry
  #  assert body["valid"] == true
  #  assert body["country"] == "US"
  #  assert body["format"] == "json"
  #  assert body["is_mobile"] == false
  #  assert body["url"] ==
  #    "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch"
  #    <> "?apiKey=us-d"
  #    <> "&keyword=nikon"
  #    <> "&visitorIPAddress=8.8.8.8"
  #    <> "&visitorUserAgent=Chrome"
  #end

  #test "dry run of a request with repeating keys", %{conn: conn} do
  #  path = search_path(conn, :dry_search, @valid_attrs)
  #  <> "&attributeValue=apple"
  #  <> "&attributeValue=banana"

  #  conn = get conn, path
  #  body = json_response(conn, 200)

  #  assert body["valid"] == true
  #  assert body["country"] == "US"
  #  assert body["format"] == "json"
  #  assert body["is_mobile"] == false
  #  assert body["url"] ==
  #    "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch"
  #    <> "?apiKey=us-d"
  #    <> "&keyword=nikon"
  #    <> "&visitorIPAddress=8.8.8.8"
  #    <> "&visitorUserAgent=Chrome"
  #    <> "&attributeValue=apple"
  #    <> "&attributeValue=banana"
  #end

  #test "dry run of an invalid request", %{conn: conn} do
  #  conn = get conn, search_path(conn, :dry_search)
  #  body = json_response(conn, 200)

  #  assert body["valid"] == false
  #end
end

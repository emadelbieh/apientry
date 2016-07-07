defmodule Apientry.SearchControllerTest do
  use Apientry.ConnCase
  import List, only: [keyfind: 3]
  import Plug.Conn, only: [put_req_header: 3]
  alias Apientry.{Feed, Publisher, TrackingId, Repo}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @gb_ip "212.58.224.22"  # bbc.co.uk
  @us_ip "216.58.221.110" # google.com
  @au_ip "203.29.5.141"   # auda.com.au

  def mock_feeds do
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "us-d", is_active: true, is_mobile: false, country_code: "US"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "us-m", is_active: true, is_mobile: true,  country_code: "US"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "gb-d", is_active: true, is_mobile: false, country_code: "GB"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "gb-m", is_active: true, is_mobile: true,  country_code: "GB"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "au-d", is_active: true, is_mobile: false, country_code: "AU"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "au-m", is_active: true, is_mobile: true,  country_code: "AU"})
  end

  def mock_publishers do
    p = Repo.insert!(%Publisher{name: "Panda", api_key: "panda-abc"})
    Repo.insert!(%TrackingId{code: "panda-a", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "panda-b", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "panda-c", publisher_id: p.id})

    p = Repo.insert!(%Publisher{name: "Avast", api_key: "avast-abc"})
    Repo.insert!(%TrackingId{code: "avast-a", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "avast-b", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "avast-c", publisher_id: p.id})

    p = Repo.insert!(%Publisher{name: "Symantec", api_key: "symantec-abc"})
    Repo.insert!(%TrackingId{code: "symantec-a", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "symantec-b", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "symantec-c", publisher_id: p.id})
  end

  test "lol test", %{conn: conn} do
    mock_feeds
    mock_publishers

    conn = get build_conn(), search_path(conn, :dry_search,
     apiKey: "panda-abc",
     trackingId: "panda-a",
     keyword: "nikon",
     visitorIPAddress: @us_ip)
    body = json_response(conn, 200)

    assert body["format"] == "json"
    assert body["country"] == "US"
    assert body["url"] ==
      "http://api.ebaycommercenetwork.com/publisher/3.0"
      <> "/json/GeneralSearch"
      <> "?apiKey=us-d"
      <> "&showOffersOnly=true"
      <> "&trackingId=8095719"
      <> "&visitorIPAddress=8.8.8.8"
      <> "&visitorUserAgent="
      <> "&keyword=nikon"
  end
end

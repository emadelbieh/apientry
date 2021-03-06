defmodule Apientry.SearcherTest do
  use Apientry.ConnCase, async: true
  alias Apientry.Searcher
  alias Apientry.Fixtures
  alias Apientry.DbCacheSupervisor

  @gb_ip "212.58.224.22"  # bbc.co.uk
  @us_ip "216.58.221.110" # google.com
  @au_ip "203.29.5.141"   # auda.com.au

  @iphone_user_agent "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
  @chrome_user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36"

  @panda_key "panda-abc"
  @default_endpoint "GeneralSearch"

  setup do
    Fixtures.mock_feeds
    Fixtures.mock_publishers
    DbCacheSupervisor.update
    :ok
  end

  #test "finding via apiKey" do
  #  body = Searcher.search("json", @default_endpoint, [
  #    {"apiKey", @panda_key},
  #    {"keyword", "nikon"},
  #    {"visitorIPAddress", @us_ip},
  #    {"visitorUserAgent", @chrome_user_agent},
  #    {"domain", "site.com"}
  #  ])

  #  expected =
  #    "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?"
  #    <> URI.encode_query(%{
  #      "apiKey" => "us-d",
  #      "keyword" => "nikon",
  #      "visitorIPAddress" => @us_ip,
  #      "visitorUserAgent" => @chrome_user_agent
  #    })

  #  assert body[:format] == "json"
  #  assert body[:country] == "US"
  #  assert body[:url] == expected
  #end

  #test "support repeating attributes" do
  #  body = Searcher.search("json", @default_endpoint, [
  #    {"apiKey", @panda_key},
  #    {"keyword", "nikon"},
  #    {"visitorIPAddress", @us_ip},
  #    {"visitorUserAgent", @chrome_user_agent},
  #    {"domain", "site.com"},
  #    {"attributeValue", "apple"},
  #    {"attributeValue", "banana"},
  #  ])

  #  expected =
  #    "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?"
  #    <> URI.encode_query(%{
  #      "apiKey" => "us-d",
  #      "keyword" => "nikon",
  #      "visitorIPAddress" => @us_ip,
  #      "visitorUserAgent" => @chrome_user_agent
  #    })
  #    <> "&attributeValue=apple"
  #    <> "&attributeValue=banana"

  #  assert body[:format] == "json"
  #  assert body[:country] == "US"
  #  assert body[:url] == expected
  #end

  #test "setting redirect_base (conn)", %{conn: conn} do
  #  conn = get conn, "/"

  #  body = Searcher.search("json", @default_endpoint, %{
  #    "apiKey" => @panda_key,
  #    "keyword" => "nikon",
  #    "visitorIPAddress" => @us_ip,
  #    "visitorUserAgent" => @chrome_user_agent,
  #    "domain" => "site.com"
  #  }, conn)

  #  assert body[:redirect_base] =~ ~r[http://.*/redirect/]
  #end

  #test "mobile check" do
  #  body = Searcher.search("json", @default_endpoint, %{
  #    "apiKey" => @panda_key,
  #    "keyword" => "nikon",
  #    "visitorIPAddress" => @us_ip,
  #    "visitorUserAgent" => @iphone_user_agent,
  #    "domain" => "site.com"
  #  })
  #  assert body[:is_mobile] == true
  #end

  #test "desktop check" do
  #  body = Searcher.search("json", @default_endpoint, %{
  #    "apiKey" => @panda_key,
  #    "keyword" => "nikon",
  #    "visitorIPAddress" => @us_ip,
  #    "visitorUserAgent" => @chrome_user_agent,
  #    "domain" => "site.com"
  #  })
  #  assert body[:is_mobile] == false
  #end

  #test "finding via apiKey (GB)" do
  #  body = Searcher.search("json", @default_endpoint, %{
  #    "apiKey" => @panda_key,
  #    "keyword" => "nikon",
  #    "visitorIPAddress" => @gb_ip,
  #    "visitorUserAgent" => @chrome_user_agent,
  #    "domain" => "site.com"
  #  })

  #  expected =
  #    "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?"
  #    <> URI.encode_query(%{
  #      "apiKey" => "gb-d",
  #      "keyword" => "nikon",
  #      "visitorIPAddress" => @gb_ip,
  #      "visitorUserAgent" => @chrome_user_agent
  #    })

  #  assert body[:format] == "json"
  #  assert body[:country] == "GB"
  #  assert body[:url] == expected
  #end

  #test "validating tracking ID" do
  #  body = Searcher.search("json", @default_endpoint, %{
  #    "apiKey" => @panda_key,
  #    "keyword" => "nikon",
  #    "visitorIPAddress" => @us_ip,
  #    "visitorUserAgent" => @chrome_user_agent,
  #    "trackingId" => "panda-a",
  #    "domain" => "site.com"
  #  })

  #  expected =
  #    "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?"
  #    <> URI.encode_query(%{
  #      "apiKey" => "us-d",
  #      "keyword" => "nikon",
  #      "visitorIPAddress" => @us_ip,
  #      "visitorUserAgent" => @chrome_user_agent,
  #      "trackingId" => "panda-a"
  #    })

  #  assert body[:format] == "json"
  #  assert body[:country] == "US"
  #  assert body[:url] == expected
  #end

  #test "validating tracking ID (invalid)" do
  #  body = Searcher.search("json", @default_endpoint, %{
  #    "apiKey" => @panda_key,
  #    "keyword" => "nikon",
  #    "trackingId" => "avant-a", # not our tracking ID!
  #    "visitorIPAddress" => @us_ip,
  #    "visitorUserAgent" => @chrome_user_agent,
  #    "domain" => "site.com"
  #  })

  #  assert body[:valid] == false
  #  assert body[:error] == :invalid_tracking_id
  #end

  #test "validating params" do
  #  body = Searcher.search("json", @default_endpoint, %{ })

  #  assert body[:valid] == false
  #  assert body[:error] == :missing_parameters
  #  assert Enum.find(body[:details][:required], & &1 == "apiKey")
  #  assert Enum.find(body[:details][:required], & &1 == "domain")
  #  assert Enum.find(body[:details][:required], & &1 == "visitorIPAddress")
  #  assert Enum.find(body[:details][:required], & &1 == "visitorUserAgent")
  #end

  #test "validating params (2)" do
  #  body = Searcher.search("json", @default_endpoint, %{"apiKey" => ""})

  #  assert body[:valid] == false
  #  assert body[:error] == :missing_parameters
  #  assert ! Enum.find(body[:details][:required], & &1 == "apiKey")
  #end
end

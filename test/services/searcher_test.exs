defmodule Apientry.SearcherTest do
  use Apientry.ModelCase
  alias Apientry.Searcher
  alias Apientry.Fixtures

  @gb_ip "212.58.224.22"  # bbc.co.uk
  @us_ip "216.58.221.110" # google.com
  @au_ip "203.29.5.141"   # auda.com.au

  @iphone_user_agent "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
  @chrome_user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36"

  @panda_key "panda-abc"

  setup do
    Fixtures.mock_feeds
    Fixtures.mock_publishers
    :ok
  end

  test "finding via apiKey" do
    body = Searcher.search("json", %{
      "apiKey" => @panda_key,
      "keyword" => "nikon",
      "visitorIPAddress" => @us_ip,
      "visitorUserAgent" => @chrome_user_agent
    })

    expected =
      "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?"
      <> URI.encode_query(%{
        "apiKey" => "us-d",
        "keyword" => "nikon",
        "showOffersOnly" => "true",
        "visitorIPAddress" => @us_ip,
        "visitorUserAgent" => @chrome_user_agent
      })

    assert body[:format] == "json"
    assert body[:country] == "US"
    assert body[:url] == expected
  end

  test "mobile check" do
    body = Searcher.search("json", %{
      "apiKey" => @panda_key,
      "keyword" => "nikon",
      "visitorIPAddress" => @us_ip,
      "visitorUserAgent" => @iphone_user_agent
    })
    assert body[:is_mobile] == true
  end

  test "desktop check" do
    body = Searcher.search("json", %{
      "apiKey" => @panda_key,
      "keyword" => "nikon",
      "visitorIPAddress" => @us_ip,
      "visitorUserAgent" => @chrome_user_agent
    })
    assert body[:is_mobile] == false
  end

  test "finding via apiKey (GB)" do
    body = Searcher.search("json", %{
      "apiKey" => @panda_key,
      "keyword" => "nikon",
      "visitorIPAddress" => @gb_ip,
      "visitorUserAgent" => @chrome_user_agent
    })

    expected =
      "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?"
      <> URI.encode_query(%{
        "apiKey" => "gb-d",
        "keyword" => "nikon",
        "showOffersOnly" => "true",
        "visitorIPAddress" => @gb_ip,
        "visitorUserAgent" => @chrome_user_agent
      })

    assert body[:format] == "json"
    assert body[:country] == "GB"
    assert body[:url] == expected
  end

  test "validating tracking ID" do
    body = Searcher.search("json", %{
      "apiKey" => @panda_key,
      "keyword" => "nikon",
      "visitorIPAddress" => @us_ip,
      "visitorUserAgent" => @chrome_user_agent,
      "trackingId" => "panda-a"
    })

    expected =
      "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?"
      <> URI.encode_query(%{
        "apiKey" => "us-d",
        "keyword" => "nikon",
        "showOffersOnly" => "true",
        "visitorIPAddress" => @us_ip,
        "visitorUserAgent" => @chrome_user_agent,
        "trackingId" => "panda-a"
      })

    assert body[:format] == "json"
    assert body[:country] == "US"
    assert body[:url] == expected
  end

  test "validating tracking ID (invalid)" do
    body = Searcher.search("json", %{
      "apiKey" => @panda_key,
      "keyword" => "nikon",
      "trackingId" => "avant-a", # not our tracking ID!
      "visitorIPAddress" => @us_ip,
      "visitorUserAgent" => @chrome_user_agent
    })

    assert body[:valid] == false
    assert body[:error] == :invalid_tracking_id
  end
end

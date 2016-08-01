defmodule Apientry.AmplitudeTest do
  use ExUnit.Case
  import Mock

  doctest Apientry.Amplitude

  setup do
    HTTPoison.start
    url = "https://api.amplitude.com/httpapi"
    headers =  %{"Content-Type": "application/json"}
    {:ok, url: url, headers: headers}
  end

  @tag :capture_log
  test_with_mock "track_publisher", %{url: url, headers: headers},
    HTTPoison, [], [post: fn _url, _body, _headers -> {:ok, "ok"} end] do
    params =
      %{
        country: "US",
        format: "json",
        is_mobile: false,
        params: %{
          "apiKey" => "us-d",
          "domain" => "site.com",
          "keyword" => "nikon",
          "visitorIPAddress" => "8.8.8.8",
          "visitorUserAgent" => "Chrome"},
        publisher_name: "Panda",
        redirect_base: "http://localhost:4001/redirect/",
        url: "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?apiKey=us-d&keyword=nikon&showOffersOnly=true&visitorIPAddress=8.8.8.8&visitorUserAgent=Chrome",
        valid: true}

    expected = %{
      event_properties: %{
        "country_code" => "US",
        "ip_address" => "8.8.8.8",
        "is_mobile" => false,
        "link" => "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?apiKey=us-d&keyword=nikon&showOffersOnly=true&visitorIPAddress=8.8.8.8&visitorUserAgent=Chrome",
        "request_domain" => "site.com",
        "endpoint" => "/",
        "user_agent" => "Chrome",
        "apiKey" => "us-d",
        "domain" => "site.com",
        "keyword" => "nikon",
        "visitorIPAddress" => "8.8.8.8",
        "visitorUserAgent" => "Chrome"
      },
      event_type: "request",
      groups: %{
        company_id: 1,
        company_name: "ebay"
      },
      ip: "8.8.8.8",
      user_id: "Panda"
    }

    body = {:form, [api_key: "13368ee3449b1b5bffa9b7253b232e9e",
                    event: Poison.encode!(expected)]}

    {:ok, pid} = Apientry.Amplitude.track_publisher(params)
    ref = Process.monitor(pid)

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}, 100
    assert called HTTPoison.post(url, body, headers)
  end

  @tag :capture_log
  test_with_mock "track_redirect", %{url: url, headers: headers},
    HTTPoison, [], [post: fn _url, _body, _headers -> {:ok, "ok"} end] do
    params = %{
      "event" => "CLICK_OFFER_URL",
      "link" => "www.example.com",
      "offer_name" => "Camera Lens"
    }

    expected = %{
      user_id: params["link"],
      event_type: "CLICK_OFFER_URL",
      event_properties: %{
        "link" => "www.example.com",
        "offer_name" => "Camera Lens"
      },
      groups: %{
        company_id: 1,
        company_name: "ebay"
      }
    }

    body = {:form, [api_key: "13368ee3449b1b5bffa9b7253b232e9e",
                    event: Poison.encode!(expected)]}

    {:ok, pid} = Apientry.Amplitude.track_redirect(params)
    ref = Process.monitor(pid)

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}, 10
    assert called HTTPoison.post(url, body, headers)
  end
end

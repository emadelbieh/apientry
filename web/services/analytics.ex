defmodule Apientry.Analytics do
  @moduledoc """
  Sends request to Blackswan Analytics (events.apientry.com)
  """

  @events Application.get_env(:apientry, :events) |> Enum.into(%{})

  @doc """
  track redirect - coupons
  """
  def track_redirect(conn, %{"dealtype" => _} = body) do
    data = Map.merge(get_common_data(body), %{
      "data" => "coupon",
      "platform" => "search",
      "subid" => body["subid"],
    })

    send_request(conn, data)
  end

  @doc """
  track redirect - offers
  """
  def track_redirect(conn, body) do
    data = Map.merge(get_common_data(body), %{
      "data" => "offer",
      "platform" => "search",
      "subid" => body["subid"],
    })

    send_request(conn, data)
  end

  @doc """
  track redirect - common data between `offers` and `coupons`
  """
  defp get_common_data(body) do
    %{
      "type" => body["event"],
      "data_details" => Poison.encode!(body),
      "url" => body["link"],
      "ip_address" => body["ip_address"],
      "publisher_id" => body["publisher_id"],
    }
  end

  @doc """
  track publisher
  """
  def track_publisher(conn, body) do
    new_properties = %{
      "request_domain" => body[:params]["domain"],
      "endpoint" => body[:params]["endpoint"] || "/",
      "ip_address" => body[:params]["visitorIPAddress"],
      "user_agent" => body[:params]["visitorUserAgent"],
      "tracking_id" => body[:params]["trackingId"],
      "country_code" => body[:country],
      "is_mobile" => body[:is_mobile],
      "link" => body[:url],
    }

    new_properties = Map.merge(body[:params], new_properties)

    body = %{
      "type" => "request",
      "data" => "offer",
      "data_details" => Poison.encode!(new_properties),
      "platform" => "search",
      "url" => body[:url],
      "ip_address" => body[:params]["visitorIPAddress"],
      "publisher_id" => body[:publisher_id]
    }

    send_request(conn, body)
  end

  @doc """
  track query - coupon
  """
  def track_query(conn, params) do
    data = %{
      "type" => "request",
      "data" => "coupon",
      "data_details" => Poison.encode!(params),
      "platform" => "search",
      "subid" => params["subid"],
      "url" => conn.assigns[:request_uri],
      "ip_address" => conn.assigns[:ip_address],
      "publisher_id" => ""
    }

    send_request(conn, data)
  end

  defp send_request(conn, body) do
    headers = %{"Content-Type": "application/json"}
    data = {:form, [
        type: body["type"],
        data: body["data"],
        data_details: body["data_details"],
        platform: body["platform"],
        subid: body["subid"] || "",
        date: now(),
        url: body["url"],
        uuid: Apientry.UUIDGenerator.generate(body["ip_address"], body["publisher_id"]),
        publisherid: "#{body["publisher_id"]}"
      ]}

    Task.start fn ->
      url = "#{@events.url}/track"
      case HTTPoison.post(url, data, headers) do
        {:ok, response} ->
          IO.puts "Sent to analytics - #{url}"
        {:error, reason} ->
          IO.puts "An error occured while sending to analytics"
          IO.inspect(reason)
      end
    end
  end

  defp now() do
    DateTime.utc_now
    |> DateTime.to_string
  end
end

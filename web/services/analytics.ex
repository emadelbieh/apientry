require IEx
defmodule Apientry.Analytics do
  @moduledoc """
  Sends request to Blackswan Analytics (events.apientry.com)
  """

  @events Application.get_env(:apientry, :events) |> Enum.into(%{})

  def track_redirect(conn, body) do
    body = %{
      "type" => body["event"],
      "data" => "offer",
      "data_details" => Poison.encode!(body),
      "platform" => "search",
      "url" => body["link"],
      "ip_address" => body["ip_address"],
      "publisher_id" => body["publisher_id"]
    }
    send_request(conn, body)
  end

  def track_publisher(conn, body) do
    new_properties = %{
      "request_domain" => body[:params]["domain"],
      "endpoint" => body[:params]["endpoint"] || "/",
      "ip_address" => body[:params]["visitorIPAddress"],
      "user_agent" => body[:params]["visitorUserAgent"],
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
      url = "#{@events.url}/track" # for easy debugging
      case HTTPoison.post(url, data, headers) do
        {:ok, _response} ->
          nil
        {:error, reason} ->
          IO.inspect(reason)
      end
    end
  end

  defp now() do
    DateTime.utc_now
    |> DateTime.to_string
  end

  import Ecto.Query
  def publisher_id_from_subid(subid) do
    Apientry.Repo.one(from s in Apientry.PublisherSubId, select: s.publisher_id, where: s.sub_id == ^subid)
  end
end

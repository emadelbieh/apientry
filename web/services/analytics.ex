defmodule Apientry.Analytics do
  @moduledoc """
  Sends request to Blackswan Analytics (events.apientry.com)
  """

  @events Application.get_env(:apientry, :events) |> Enum.into(%{})

  def track_redirect(conn, body) do
    send_request(conn, body)
  end

  defp send_request(conn, body) do
    headers = %{"Content-Type": "application/json"}
    data = {:form, [
        type: body["event"],
        data: "offer",
        data_details: Poison.encode!(body),
        platform: "search",
        subid: body["subid"],
        date: now(),
        url: body["link"],
        uuid: Apientry.UUIDGenerator.generate(body["ip_address"], body["publisher_id"]),
        publisherid: body["publisher_id"]
      ]}

    Task.start fn ->
      case HTTPoison.post("#{@events.url}/track", data, headers) do
        {:ok, response} ->
          IO.inspect(response)
        {:error, reason} ->
          IO.puts(reason)
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

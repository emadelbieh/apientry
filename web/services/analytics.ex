require IEx

defmodule Apientry.Analytics do
  @moduledoc """
  Sends request to Blackswan Analytics (events.apientry.com)
  """

  @events Application.get_env(:apientry, :events) |> Enum.into(%{})

  def track_redirect(conn, body) do
    IEx.pry

    params = %{
      user_id: body["link"], # Using this for now as it's the only required field
      event_type: body["event"],
      event_properties: Map.delete(body, "event"),
      groups: %{
        company_id: 1,
        company_name: "ebay"
      }
    }

    send_request(conn, params)
  end

  defp send_request(conn, params) do
    headers = %{"Content-Type": "application/json"}
    data = {:form, [
        type: params["event_type"],
        data: "offer",
        data_details: params,
        subid: @events.subid,
        date: now(),
        url: params.link,
        uuid: @events.uuid,
        publisher_id: publisher_from_sub_id(conn.assigns["subid"])
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
  def publisher_from_subid(subid) do
    Repo.one(from s in Apientry.PublisherSubId, select: s.id, where: s.sub_id == ^subid)
  end
end

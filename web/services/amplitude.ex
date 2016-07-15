defmodule Apientry.Amplitude do
  @moduledoc """
  Amplitude.com API
  """

  @amplitude Application.get_env(:apientry, :amplitude) |> Enum.into(%{})

  def track_publisher(body) do
    params = %{
      user_id: body[:publisher_name],
      event_type: "request",
      ip: body[:params]["visitorIPAddress"],
      user_properties: %{
        ip_address: body[:params]["visitorIPAddress"],
        country: body[:country],
        is_mobile: body[:is_mobile],
        link: body[:url],
        keyword: body[:params]["keyword"],
        user_agent: body[:params]["visitorUserAgent"],
        request_domain: body[:params]["domain"],
      },
      groups: %{
        company_name: "ebay"
      }
    }

    send_request(params)
  end

  def track_redirect(body) do
    params = %{
      user_id: body["link"], # Using this for now as it's the only required field
      event_type: "redirect",
      user_properties: body,
      groups: %{
        company_name: "ebay"
      }
    }

    send_request(params)
  end

  def send_request(params) do
    headers = %{"Content-Type": "application/json"}
    data = {:form, [api_key: @amplitude.api_key, event: Poison.encode!(params)]}

    Task.start fn ->
      case HTTPoison.post(@amplitude.url, data, headers) do
        {:ok, response} ->
          IO.puts "\n\nAmplitude response: #{inspect response} \n\n"

        {:error, reason} ->
          IO.puts "\n\nAmplitude error: #{inspect reason} \n\n"
      end
    end
  end

end

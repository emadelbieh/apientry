defmodule Apientry.Amplitude do
  @moduledoc """
  Amplitude.com API sender.

  ## References

  - [Amplitude HTTP API reference](https://amplitude.zendesk.com/hc/en-us/articles/204771828)
  - [Property list as of v1.1.0](https://github.com/blackswan-ventures/apientry/issues/65#issuecomment-233222630)
  """

  @amplitude Application.get_env(:apientry, :amplitude) |> Enum.into(%{})

  @event_names %{
    "CLICK_ATTRIBUTEVALUE_URL" => true,
    "CLICK_ATTRIBUTE_URL" => true,
    "CLICK_CATEGORY_URL" => true,
    "CLICK_OFFER_URL" => true,
    "CLICK_PRODUCT_URL" => true,
    "CLICK_REVIEW_URL" => true,
  }

  def track_publisher(body) do
    new_properties = %{
      "request_domain" => body[:params]["domain"],
      "ip_address" => body[:params]["visitorIPAddress"],
      "user_agent" => body[:params]["visitorUserAgent"],
      "country_code" => body[:country],
      "is_mobile" => body[:is_mobile],
      "link" => body[:url],
    }

    params = %{
      user_id: body[:publisher_name],
      event_type: "request",
      ip: body[:params]["visitorIPAddress"],
      event_properties: Map.merge(body[:params], new_properties),
      groups: %{
        company_id: 1,
        company_name: "ebay"
      }
    }

    send_request(params)
  end

  def track_redirect(body) do
    params = %{
      user_id: body["link"], # Using this for now as it's the only required field
      event_type: body["event"],
      event_properties: Map.delete(body, "event"),
      groups: %{
        company_id: 1,
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

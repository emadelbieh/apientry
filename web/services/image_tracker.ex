defmodule Apientry.ImageTracker do
  @api_key "f299155a-9ee2-4243-8ece-a8a4fe96fed6"
  @tracking_id "8095835"
  @host_details "https://api.apientry.com/publisher"
  @unwanted_keys ~w(request_domain user_agent country_code is_mobile ip_address link)a

  def track_anomalies(json) do
    json
    |> Map.drop(@unwanted_keys)
    |> Map.put(:apiKey, @apiKey)
    |> Map.put(:trackingId, @trackingId)
    |> URI.encode_query
    |> prepend_host_details
    |> http_get!
  end

  defp prepend_host_details(query_string) do
    @host_details <> "?" <> query_string
  end

  defp http_get!(url) do
    HTTPoison.get!(url)
  end
end

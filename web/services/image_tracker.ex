defmodule Apientry.ImageTracker do
  @api_key "f299155a-9ee2-4243-8ece-a8a4fe96fed6"
  @tracking_id "8095835"
  @unwanted_keys ~w(request_domain user_agent country_code is_mobile ip_address link)a

  def track_anomalies(json) do
    json
    |> remove_keys(@unwanted_keys)
    |> Map.put(:apiKey, @apiKey)
    |> Map.put(:trackingId, @trackingId)
    |> URI.encode_query
    |> prepend_host_details
    |> http_get
  end

  def remove_keys(map, keys) do
    keys |> Enum.reduce(map, fn(key, result) ->
      Map.delete(result, key)
    end)
  end

  def prepend_host_details(query_string) do
    "https://api.apientry.com/publisher?" <> query_string
  end

  def http_get(url) do
    HTTPoison.get! url
  end
end

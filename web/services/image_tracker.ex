defmodule Apientry.ImageTracker do
  @unwanted_keys ~w(request_domain user_agent country_code is_mobile ip_address link)a

  def track_anomalies(json) do
    json |> remove_keys(@unwanted_keys)
  end

  def remove_keys(map, keys) do
    keys |> Enum.reduce(map, fn(key, result) ->
      Map.delete(result, key)
    end)
  end
end

defmodule Apientry.ImageTracker do
  def track_anomalous_images(body) do
    case get_image_urls(body) do
      {:ok, images} ->
        for image_url < images do
          # TODO: extract
          Task.start(fn ->
            {:ok, data} = HTTPoison.get(image_url)
            status = data.status_code
            headers = data.headers |> Enum.into(%{})
            content_length = headers["Content-Length"] |> String.to_integer
            unless status in 200..299 && content_length > 0 do
              # TODO: extract / use ErrorReporter module
              Task.start(fn ->
                payload = %{
                  "access_token": "",
                  "data" : {
                    "environment": "",
                    "body": {
                      "message": {
                        "body": "Status is not in 200..299 or Content-Length is less than 1",
                        "url": image_url
                      }
                    }
                  }
                }
              end)
            end
          end)
        end
      _ ->
        :error
    end
  end

  def get_image_urls(body) do
    body
    |> extract_categories
    |> extract_items
    |> extract_images
    |> Enum.map(fn image -> image["sourceURL"] end)
  end

  def track_images(conn, body) do
    case get_image_urls(body) do
      {:ok, images} ->
        Apientry.Amplitude.track_images(conn, images)
        {:ok, images}
      _ ->
        :error
    end
  end

  defp extract_categories(%{"categories" => %{"category" => categories}}) do
    {:ok, categories}
  end
  defp extract_categories(_) do
    :error
  end

  defp extract_items({:ok, categories}) do
    items = Stream.flat_map(categories, fn category ->
      %{"items" => %{"item" => items}} = category
      items
    end)
    {:ok, items}
  end
  defp extract_items(_) do
    :error
  end

  defp extract_images({:ok, items}) do
    Stream.flat_map(items, fn item ->
      cond do
        item["offer"] ->
          %{"offer" => %{"imageList" => %{"image" => images}}} = item
          images
        true ->
          []
      end
    end)
  end
  defp extract_images(_) do
    []
  end
end

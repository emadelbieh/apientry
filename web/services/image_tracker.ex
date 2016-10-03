defmodule Apientry.ImageTracker do
  def get_image_urls(body) do
    body
    |> extract_categories
    |> extract_items
    |> extract_images
    |> Enum.map(fn image -> image["sourceURL"] end)
  end

  @doc """
  Gets image urls from the result of the query and list them on Amplitude.
  Images that are anomalous gets listed to Rollbar.
  """
  def track_images(conn, body) do
    images = get_image_urls(body)
    Apientry.Amplitude.track_images(conn, images)
    track_anomalous_images(conn, images)
  end

  defp track_anomalous_images(conn, image_urls) do
    for image_url <- image_urls do
      Task.start(fn ->
        {:ok, metadata} = HTTPoison.get(image_url)
        Apientry.ErrorReporter.track_anomalous_image(conn, metadata, image_url)
      end)
    end
  end

  defp extract_categories(body) do
    %{"categories" => %{"category" => categories}} = body
    categories
  end

  defp extract_items(categories) do
    Enum.flat_map(categories, fn category ->
      %{"items" => %{"item" => items}} = category
      items
    end)
  end

  defp extract_images(items) do
    Enum.flat_map(items, fn item ->
      %{"product" => %{"images" => %{"image" => images}}} = item
      images
    end)
  end
end

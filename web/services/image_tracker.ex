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
    case get_image_urls(body) do
      {:ok, images} ->
        Apientry.Amplitude.track_images(conn, images)
        track_anomalous_images(conn, images)
        {:ok, images}
      _ ->
        :error
    end
  end

  defp track_anomalous_images(conn, image_urls) do
    for image_url <- image_urls do
      Task.start(fn ->
        {:ok, metadata} = HTTPoison.get(image_url)
        Apientry.ErrorReporter.track_anomalous_image(conn, metadata, image_url)
      end)
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

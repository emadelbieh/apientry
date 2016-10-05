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
    anomalous = track_anomalous_images(images)
    Apientry.Amplitude.track_images(conn, images, anomalous)
  end

  defp track_anomalous_images(image_urls) do
    Stream.map(image_urls, fn image_url ->
      case HTTPoison.get(image_url) do
        {:ok, metadata} ->
          track_anomalous_image(metadata, image_url)
        {:error, _httpoison_error} ->
          image_url
      end
    end)
    |> Enum.filter(fn url -> url != nil end)
  end

  def track_anomalous_image(%{status_code: status, headers: headers}, image_url) do
    headers = headers |> Enum.into(%{})
    content_length = headers["Content-Length"] || headers["content-length"]

    unless status in 200..299 && content_length != "0" do
      image_url
    end
  end

  defp extract_categories(%{"categories" => %{"category" => categories}}) do
    {:ok, categories}
  end
  defp extract_categories(_) do
    :error
  end


  defp extract_items({:ok, categories}) do
    items = Enum.flat_map(categories, fn category ->
      %{"items" => %{"item" => items}} = category
      items
    end)
    {:ok, items}
  end
  defp extract_items(_) do
    :error
  end

  defp extract_images({:ok, items}) do
    Enum.flat_map(items, fn item ->
      cond do
        item["product"] ->
          %{"product" => %{"images" => %{"image" => images}}} = item
          images
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

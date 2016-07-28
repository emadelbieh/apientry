defmodule Apientry.ImageTracker do
  def extract_urls(body) do
    # TODO: currently runs in O(CN). parallelism might yield O(log n)
    body
    |> extract_categories
    |> extract_items
    |> extract_images
    |> extract_source_urls
  end

  def track_to_amplitude do
    # TODO: implement me
  end

  defp extract_categories(body) do
    %{"categories" => %{"category" => categories}} = body
    categories
  end

  defp extract_items(categories) do
    Enum.map(categories, fn category ->
      %{"items" => %{"item" => items}} = category
      items
    end)
    |> List.flatten
  end

  defp extract_images(items) do
    Enum.map(items, fn item ->
      %{"offer" => %{"imageList" => %{"image" => images}}} = item
      images
    end)
    |> List.flatten
  end

  defp extract_source_urls(images) do
    Enum.map(images, fn image ->
      %{"sourceURL" => url} = image
      url
    end)
    |> List.flatten
  end
end

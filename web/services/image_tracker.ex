defmodule Apientry.ImageTracker do
  def get_image_urls(body) do
    body
    |> extract_categories
    |> extract_items
    |> extract_images
    |> Enum.map(fn image -> image["sourceURL"] end)
  end

  def track(image_urls) do
    # TODO: implement me
  end

  defp extract_categories(body) do
    %{"categories" => %{"category" => categories}} = body
    categories
  end

  defp extract_items(categories) do
    Stream.flat_map(categories, fn category ->
      %{"items" => %{"item" => items}} = category
      items
    end)
  end

  defp extract_images(items) do
    Stream.flat_map(items, fn item ->
      %{"offer" => %{"imageList" => %{"image" => images}}} = item
      images
    end)
  end
end

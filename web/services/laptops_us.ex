defmodule Apientry.LaptopsUS do
  @category_id "9007"

  @attribute_values []

  @rules ~r/(\b\d{1,3}gb\b|\b\d{1,3}tb\b|\bcore i|ssd|windows 10)/

  @regex ~r/laptop|macbook|notebook/

  def process(data) do
    title = data.keywords

    if String.length(title) > 5 && title =~ @regex && title =~ @rules do
      Map.put(data, :has_match, true)
    else
      data
    end
  end
end

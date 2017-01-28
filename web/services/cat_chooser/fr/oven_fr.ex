defmodule Apientry.OvenFR do
  @category_id "1896"

  @attribute_values []

  @regex ~r/(\belectromen\b|\bfour\b)/

  def process(data) do
    if data.breadcrumbs =~ @regex do
      Map.merge(data, %{
        category_id: @category_id,
        attribute_values: @attribute_values
      })
    else
      data
    end
  end
end

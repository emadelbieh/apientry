defmodule Apientry.MicrowaveFR do
  @category_id "1892"

  @attribute_values []

  @regex ~r/(\micro onde|\bmicroonde)/i

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

defmodule Apientry.SofaFR do
  @category_id "73188"

  @attribute_values []
  
  @regex ~r/(\bcanapé)/i

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

defmodule Apientry.TvFR do
  @category_id "96252"

  @attribute_values []

  @regex ~r/(télévision|téléviseur)/i

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

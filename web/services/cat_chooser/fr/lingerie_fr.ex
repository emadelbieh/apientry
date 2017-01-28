defmodule Apientry.LingerieFR do
  @category_id "96667"

  @attribute_values []

  @regex = ~r/lingerie/

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

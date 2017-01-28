defmodule Apientry.ShoesFR do
  @category_id "96602"

  @attribute_values []

  @rules ~r/chaussur/

  @regex ~r/\bet\b/

  def process(data) do
    str = Apientry.Rerank.tokenize(data.breadcrumbs, "fr")
    str = Enum.join(str, " ")

    if(str =~ @rules && str =~ @regex) do
      Map.merge(data, %{
        category_id: @category_id,
        attribute_values: @attribute_values
      })
    else
      data
    end
  end
end

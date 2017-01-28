defmodule Apientry.BagsFR do
  @category_id "96668"

  @attribute_values []

  @regex ~r/(SAC BOURSE|sac bours|sac cab|sac main|sac band    ouli|sac reversibl|sac epaul|Sacs main|Sacs pochette|Sacs à dos|Sacs dos)/i

  def process(data) do
    title = data.keywords

    if(title && String.length(title)>0 && title =~ regex) do
      Map.merge(data, %{
        category_id: @category_id,
        attribute_values: @attribute_values
      })
    else
      data
    end
  end
end

defmodule Apientry.Helpers do
  def regex_strings do
    Path.expand(".")
    |> Path.join("/web/services/us_cat_id_attr_regex.csv")
    |> File.stream!()
    |> CSV.decode()
    |> Enum.reduce(%{}, fn [cat_id, regex], acc ->
      Map.put(acc, cat_id, regex)
    end)
  end
end

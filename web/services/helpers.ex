defmodule Apientry.Helpers do
  def regex_strings do
    File.stream!("web/services/us_cat_id_attr_regex.csv")
    |> CSV.decode()
    |> Enum.reduce(%{}, fn [cat_id, regex], acc -> Map.put(acc, cat_id, regex) end)
  end
end

defmodule Apientry.Helpers do
  def regex_strings(geo) do
    Path.expand(".")
    |> Path.join("/web/services/#{geo}_cat_id_attr_regex.csv")
    |> File.stream!()
    |> CSV.decode()
    |> Enum.reduce(%{}, fn [cat_id, regex], acc ->
      Map.put(acc, cat_id, regex)
    end)
  end
end

defmodule Apientry.Helpers do
  def regex_strings(geo) do
    case CsvCacheRegistry.lookup(CsvCacheRegistry, geo) do
      {:ok, cache} ->
        if CsvCache.get(cache, "31515") do
          # do nothing
          cache
        else
          load_regexes_from_file(cache, geo)
          cache
        end
      :error ->
        CsvCacheRegistry.create(CsvCacheRegistry, geo)
        {:ok, cache} = CsvCacheRegistry.lookup(CsvCacheRegistry, geo)
        load_regexes_from_file(cache, geo)
        cache
    end
  end

  def load_regexes_from_file(cache, geo) when geo in ~w(fr us au de gb) do
    try do
      Path.expand(".")
      |> Path.join("/web/services/#{geo}_cat_id_attr_regex.csv")
      |> File.stream!()
      |> CSV.decode()
      |> Enum.each(fn [cat_id, regex] ->
        CsvCache.put(cache, cat_id, regex)
      end)
      #|> Enum.reduce(%{}, fn [cat_id, regex], acc ->
      #  Map.put(acc, cat_id, regex)
      #end)
    rescue
      File.Error ->
        Path.expand("~")
        |> Path.join("/#{geo}_cat_id_attr_regex.csv")
        |> File.stream!()
        |> CSV.decode()
        |> Enum.each(fn [cat_id, regex] ->
          CsvCache.put(cache, cat_id, regex)
        end)
        #|> Enum.reduce(%{}, fn [cat_id, regex], acc ->
        #  Map.put(acc, cat_id, regex)
        #end)
    end
  end

  def load_regexes_from_file(_, _) do
    # do nothing
  end
end

defmodule Apientry.EbayXmlTransformer do
  def transform(map) do
    {"result", %{}, do_transform(map)}
  end

  def do_transform(map) when is_map(map) do
    Enum.map(map, fn {key, value} ->
      properties = cond do
        is_list(value) -> %{type: "array"}
        true -> %{}
      end
      value = normalize_value(key, value)
      {key, properties, do_transform(value)}
    end)
  end

  def do_transform(list) when is_list(list) do
    Enum.flat_map(list, fn element ->
      do_transform(element)
    end)
  end

  def do_transform(value) do
    value
  end

  # handles edge case: %{ "upc" => ["1234567890", "0987654321"] }
  # transforms it to: %{ "upc" => [%{upc => "1234567890", upc => "0987654321"}]}
  defp normalize_value(key, value) do
    cond do
      value == [] ->
        nil
      is_list(value) ->
        if is_binary(hd(value)) do
          Enum.map(value, fn element -> %{key => element} end)
        else
          value
        end
      true -> value
    end
  end
end

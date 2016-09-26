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
end

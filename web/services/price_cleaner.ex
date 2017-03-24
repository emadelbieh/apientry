defmodule Apientry.PriceCleaner do
  def new(price) do
    price
  end

  def clean(price) do
    cond do
      price == nil || price == 0 ->
        nil
      is_float(price) && price>0 ->
        price
      true ->
        logic_from_js(price)
    end
  end

  defp logic_from_js(price) do
    price = String.trim(price)
    length = String.length(price)

    pos = length - 3

    price = if String.at(price, pos) == "€" do
      replace(price, pos, ".")
    else
      price
    end

    price = if String.at(price, pos) == "," do
      replace(price, pos, ".")
    else
      price
    end
  end

  defp replace(price, position, with) do
    {first, last} = String.split_at(position)
    last = String.slice(last, 1, String.length(last)-1)
    "#{first}#{with}#{last}"
  end
end

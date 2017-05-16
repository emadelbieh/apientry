defmodule Apientry.PriceCleaner do
  def clean(price) do
    {price, _} = price
    |> get_lower_bound()
    |> String.trim()
    |> String.codepoints()
    |> Enum.reverse()
    |> substring_from_first_digit()
    |> fix_decimal_delimiter()
    |> Enum.reverse()
    |> substring_from_first_digit()
    |> Enum.reject(fn char -> char =~ ~r/\s+/ end)
    |> Enum.reject(fn char -> char == "," end)
    |> List.to_string()
    |> Float.parse()

    price
  end

  def get_lower_bound(price) do
    case String.split(price, "-") do
      [lower | _higher] -> lower
      [price] -> price
    end
  end
  
  def fix_decimal_delimiter([_, _, delimiter | _] = reversed_codepoints) when delimiter in ["€", ","] do
    reversed_codepoints
    |> Enum.map(fn char ->
      if char == ".", do: ",", else: char
    end)
    |> List.replace_at(2, ".")
  end

  def fix_decimal_delimiter(codepoints) do
    codepoints
  end

  def substring_from_first_digit(codepoints) do
    index = codepoints |> Enum.find_index(&(&1 =~ ~r/[0-9]/))
    Enum.slice(codepoints, index..-1)
  end
end

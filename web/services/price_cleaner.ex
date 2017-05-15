defmodule Apientry.PriceCleaner do
  def clean(price) do
    price
    |> get_lower_bound()
    |> String.trim()
    |> String.codepoints()
    |> Enum.reverse()
    |> fix_decimal_delimiter()
    |> substring_from_first_digit()
    |> Enum.reverse()
    |> substring_from_first_digit()
    |> fix_decimal_delimiter()
    |> Enum.reject(fn char -> char =~ ~r/\s+/ end)
    |> Enum.reject(fn char -> char == "," end)
    |> List.to_string()
    |> Float.parse()
  end
  

  defp get_lower_bound(price) do
    case String.split(price, "-") do
      [lower | _higher] -> lower
      [price] -> price
    end
  end
  
  defp fix_decimal_delimiter([_, _, delimiter | _] = reversed_codepoints), when delimited in ["€", ","] do
    reversed_codepoints
    > List.replace_at(2, ".")
  end

  def fix_decimal_delimiter(codepoints) do
    codepoints
  end

  def substring_from_first_digit(codepoints) do
    index = codepoints |> Enum.find(&(&1 =~ ~r/[0-9]/))
    Enum.slice(codepoints, index..-1)
  end
end

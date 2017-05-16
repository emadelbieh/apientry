defmodule Apientry.PriceGenerator do
  def get_min_max(price) do
    delta = get_delta(price)
    min = price - delta
    max = price + delta
    [min, max] = [apply_lower_bound(min, 0.0), apply_lower_bound(max, 15.0)]
    [min, max] = [two_decimal_places(min), two_decimal_places(max)]
  end

  defp get_delta(price) do
    cond do
      price < 30 ->
        0.5 * price
      price < 100 ->
        0.35 * price
      price < 500 ->
        0.25 * price
      true ->
        0.15 * price
    end
  end

  defp apply_lower_bound(value, min) do
    if value < min, do: min, else: value
  end

  defp two_decimal_places(value) do
    Float.round(value, 2)
  end
end

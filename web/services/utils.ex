defmodule Utils do

  shopping_stop_words = [
    "avec offres spéciales",
    "peter hahn",
    "fiyatı",
    "undefined",
    "offres spéciales"
  ]
  
  shopping_stop_words_reg = nil
  
  def set_shopping_stop_words_reg() do
  end
  
  def to_base_64(data) do
    Base.encode64(data)
  end

  def from_base_64(data) do
    Base.decode64(data)
  end

  def redirect(data) do
  end

  def clean_price(nil), do: nil
  def clean_price(0), do: nil
  def clean_price(price) when is_number(price) do
    if price > 0 do
      price
    else
      nil
    end
  end
  def clean_price(price, domain) do
    String.trim(price)
  end

  def get_max_min_price(0), do: nil
  def get_max_min_price(nil), do: nil
  def get_max_min_price(price) do
    if String.length(price) < 2 do
      nil
    else
      # should price first be converted to a fixnum here?

      delta = cond do
        price < 30 ->
          price * 0.5
        (price >= 30 && price < 100) ->
          price * 0.35
        (price >= 100 && price < 500) ->
          price * 0.25
        (price >= 500) ->
          price * 0.15
      end

      min = price - delta
      max = price + delta

      max = if max < 15, do: 15

      %{min: min, max: max}
    end

  end

  def random_int_from_interval(min, max) do
    :math.floor(:random.uniform * (max - min + 1) + min)
  end
end

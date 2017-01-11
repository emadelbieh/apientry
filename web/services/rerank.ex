defmodule Apientry.Rerank do
  @min_cat_size 0.1

  def format_ebay_results_for_rerank(ebay_results) do
    Enum.map(ebay_results, fn category ->
      %{
        cat_name: category.name,
        cat_id: category.id,
        offers: Enum.map(category.items.item, fn item ->
          %{
            title: item.offer.name,
            price: item.offer.basePrice.value
          }
        end)
      }
    end)
  end

  def remove_duplicate(categories) do
    Enum.map(categories, fn category ->
      offers = Enum.uniq_by(category.offers, fn offer ->
        "#{offer.title} #{offer.price}"
      end)
      category = Map.put(category, :offers, offers)
    end)
  end


  def remove_small_categories(categories) do
    threshold = Float.ceil(@min_cat_size * count_total_offers(categories))

    result = Enum.reject(categories, fn category ->
      length(category.offers) < threshold
    end)
  end

  def get_max_cat_price(category) do
    most_expensive_offer = Enum.max_by(category.offers, fn offer ->
      offer.price
    end)
    most_expensive_offer.price
  end

  defp count_total_offers(categories) do
    Enum.map(categories, fn category ->
      length(category.offers)
    end)
    |> Enum.sum
  end

  def calculate_price_val(offer, max_cat_price) do
    1 - (offer.price / max_cat_price)
  end

  def add_price_val(offers, max_cat_price, calculator) do
    Enum.map(offers, fn offer ->
      Map.put(offer, :price_val, calculator.(offer, max_cat_price))
    end)
  end
end

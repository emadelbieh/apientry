defmodule Apientry.Rerank do
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
end

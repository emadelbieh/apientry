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
end

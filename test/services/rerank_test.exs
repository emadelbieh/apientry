defmodule Apientry.RerankTest do
  use ExUnit.Case
  
  test "formatting" do
    original = [%{
      id: 1,
      name: "Category",
      items: %{
        item: [
          %{offer: %{name: "Offer 1", basePrice: %{value: 19.99}}},
          %{offer: %{name: "Offer 2", basePrice: %{value: 20.89}}}
        ]
      }
    }]

    result = hd(Apientry.Rerank.format_ebay_results_for_rerank(original))
    assert result.cat_name == "Category"
    assert result.cat_id == 1

    offer1 = hd(result.offers)
    assert offer1.title == "Offer 1"
    assert offer1.price == 19.99


    offer2 = hd(tl(result.offers))
    assert offer2.title == "Offer 2"
    assert offer2.price == 20.89
  end

  test "remove duplicate" do
    internal_data = [
      %{
        cat_id: 1,
        cat_name: "Category",
        offers: [
          %{ title: "Offer 1", price: 19.99 },
          %{ title: "Offer 1", price: 19.99 }
        ]
      }
    ]

    expected = [
      %{
        cat_id: 1,
        cat_name: "Category",
        offers: [
          %{ title: "Offer 1", price: 19.99 }
        ]
      }
    ]

    result = Apientry.Rerank.remove_duplicate(internal_data)

    assert result == expected
  end

  test "remove small categories" do
    internal_data = [
      %{ cat_id: 1,
         cat_name: "Category 1",
         offers: [
           %{title: "Offer 1", price: 19.19},
           %{title: "Offer 2", price: 19.19},
           %{title: "Offer 3", price: 19.19},
           %{title: "Offer 4", price: 19.19},
           %{title: "Offer 5", price: 19.19},
           %{title: "Offer 6", price: 19.19},
           %{title: "Offer 7", price: 19.19},
           %{title: "Offer 8", price: 19.19},
           %{title: "Offer 9", price: 19.19},
           %{title: "Offer 10", price: 19.19}
         ]},
      %{ cat_id: 2,
         cat_name: "Category 2",
         offers: [
           %{title: "Offer 12", price: 19.19}
         ]}
    ]

    result = Apientry.Rerank.remove_small_categories(internal_data)
    category = hd(result)

    assert length(result) == 1
    assert length(category.offers) == 10
  end
end

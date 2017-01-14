defmodule Apientry.RerankTest do
  use ExUnit.Case
  
  test "formatting" do
    original = [%{
      "id" => 1,
      "name" => "Category",
      "items" => %{
        "item" => [
          %{"offer" => %{"name" => "Offer 1", "basePrice" => %{"value" => "19.99"}}},
          %{"offer" => %{"name" => "Offer 2", "basePrice" => %{"value" => "20.89"}}}
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

  test "max category price" do
    internal_data = %{
      cat_id: 1,
      cat_name: "Category 1",
      offers: [
        %{title: "Offer 1", price: 19.99},
        %{title: "Offer 1", price: 49.99},
        %{title: "Offer 1", price: 32.99}
      ]
    }

    result = Apientry.Rerank.get_max_cat_price(internal_data)
    assert result == 49.99
  end

  test "calculate price val" do
    max_cat_price = 20;
    offer = %{
      price: 18
    }
    result = Apientry.Rerank.calculate_price_val(offer, max_cat_price)

    assert_in_delta(result, 0.10, 0.000001)
  end

  test "adding_of_price_val" do
    offers = [
      %{title: "test1"},
      %{title: "test2"}
    ]

    result = Apientry.Rerank.add_price_val(offers, 7, fn _, _ -> 7 end)

    assert hd(result).price_val == 7
    assert hd(tl(result)).price_val == 7
  end

  test "normalization of token values" do
    data = [
      %{offers: [%{token_val: 2}]},
      %{offers: [%{token_val: 3}]}
    ]

    result = Apientry.Rerank.normalize_token_vals(data, 3)

    offers1 = hd(result).offers
    offers2 = hd(tl(result)).offers

    token_val1 = hd(offers1).token_val
    token_val2 = hd(offers2).token_val

    assert_in_delta(token_val1, 0.666666667, 000000001)
    assert token_val2 == 1
  end

  test "add_prod_vals adds weighted val to each offers based on token_val and price_val" do
    data = [
      %{ offers: [%{ token_val: 1, price_val: 3 }] },
      %{ offers: [%{ token_val: 2, price_val: 2 }] },
    ]

    result = Apientry.Rerank.add_prod_val(data)

    category1 = hd(result)
    category2 = hd(tl(result))

    offer1 = hd(category1.offers)
    offer2 = hd(category2.offers)

    assert_in_delta(offer1.val, 2.4, 0.0000001)
    assert offer2.val == 2.0
  end

  test "sort_categories sorts categories by category value" do
    data = [
      %{ cat_name: "Category 1", val: 6},
      %{ cat_name: "Category 2", val: 5},
      %{ cat_name: "Category 3", val: 7},
    ]

    result = Apientry.Rerank.sort_categories(data)

    names = Enum.map(result, fn category -> category.cat_name end)
    assert names == ["Category 3", "Category 1", "Category 2"]
  end

  test "sort_products_within_categories sorts offers by val" do
    categories = [
      %{ cat_name: "Category 1", offers: [
        %{val: 6}, %{val: 5}, %{val: 7}
      ]}
    ]

    result = hd(Apientry.Rerank.sort_products_within_categories(categories))

    vals = Enum.map(result.offers, fn offer ->
      offer.val
    end)

    assert vals == [7, 6, 5]
  end

  test "get_top_ten_offers returns the top 10 offers accross all categories" do
    data = [
      %{offers: [%{val: 1},  %{val: 2},  %{val: 3}]},
      %{offers: [%{val: 4},  %{val: 5},  %{val: 6}]},
      %{offers: [%{val: 7},  %{val: 8},  %{val: 9}]},
      %{offers: [%{val: 10}, %{val: 11}, %{val: 12}]}
    ]

    offers = Apientry.Rerank.get_top_ten_offers(data)
    assert length(offers) == 10

    vals = Enum.map(offers, fn offer -> offer.val end)
    assert vals == [1,2,3,4,5,6,7,8,9,10]
  end

  test "get_max_offer_token_val returns the highest token val" do
    data = [
      %{offers: [%{token_val: 11}, %{token_val: 12}, %{token_val: 13}]},
      %{offers: [%{token_val: 14}, %{token_val: 15}, %{token_val: 16}]},
      %{offers: [%{token_val: 17}, %{token_val: 18}, %{token_val: 19}]},
      %{offers: [%{token_val: 10}, %{token_val: 11}, %{token_val: 12}]}
    ]

    max = Apientry.Rerank.get_max_offer_token_val(data)

    assert max == 19
  end

  test "normalize_string removes leading and trailing spaces" do
    result = Apientry.Rerank.normalize_string("    test   ")
    assert result == "test"
  end

  test "normalize_string replaces double spaces with a single one" do
    result = Apientry.Rerank.normalize_string("this   is   a test")
    assert result == "this is a test"
  end

  test "normalize_string downcases everything" do
    result = Apientry.Rerank.normalize_string("heyThereHeyThere")
    assert result == "heythereheythere"
  end

  test "normalize_string replaces é with e" do
    result = Apientry.Rerank.normalize_string("Lés Fils Du Vent")
    assert result == "les fils du vent"
  end

  test "normalize_string removes special characters" do
    result = Apientry.Rerank.normalize_string("-®|():,’_+&!%*$@#;^/'\\")
    assert result == ""
  end

  test "get_num_of_attrs_name_contained_in_product returns number of attributes present in offer title" do
    offer = %{title: "The rain in SPAIN stays mainly in the plain"}
    attributes_from_ebay = ["ain", "in"]

    result = Apientry.Rerank.get_num_of_attrs_name_contained_in_product(attributes_from_ebay, "us", offer)

    assert result == 2
  end
end

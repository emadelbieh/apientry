defmodule Apientry.Rerank do
  @min_cat_size 0.1

  def get_products(conn, ebay_results, search_term, geo, fetched_url) do
    geo = geo || "";

    regex_cache = Apientry.TitleWeightService.prepare_regex_cache(conn, geo)

    categories = ebay_results
    categories = format_ebay_results_for_rerank(categories)
    categories = remove_duplicate(categories)
    categories = remove_small_categories(categories)

    regex_cache = Task.await(regex_cache)
    categories = Enum.map(categories, fn category ->
      regex_string = CsvCache.get(regex_cache, category.cat_id) || ""
      {:ok, regex} = regex_string |> Regex.compile()

      max_cat_price = get_max_cat_price(category)

      offers = category.offers
      offers = Apientry.TitleWeightService.add_token_val(conn, offers, search_term, geo, regex, fetched_url)
      offers = add_price_val(offers, max_cat_price)

      Map.put(category, :offers, offers)
    end)

    max_offer_token_val = get_max_offer_token_val(categories)
    categories = normalize_token_vals(categories, max_offer_token_val)
    categories = add_prod_val(categories)
    categories = add_category_token_vals(categories)
    categories = add_cat_val(conn, categories)
    categories = sort_categories(categories)
    categories = sort_products_within_categories(categories)

    get_top_ten_offers(categories, conn)
    |> Enum.map(fn offer -> offer.original_item end)
  end

  # refactored from format_ebay_results_for_rerank
  def extract_offers(ebay_items) do
    ebay_items
    |> ParallelStream.filter(fn item -> item["offer"] end)
    |> ParallelStream.map(fn item ->
      {price, _} = Float.parse(item["offer"]["basePrice"]["value"])
      %{
        title: item["offer"]["name"],
        price: price,
        original_item: item
      }
    end)
    |> Enum.into([])
  end

  def format_ebay_results_for_rerank(ebay_results) do
    ebay_results
    |> ParallelStream.map(fn category ->
      %{
        cat_name: category["name"],
        cat_id: category["id"],
        offers: extract_offers(category["items"]["item"])
      }
    end)
  end

  def remove_duplicate(categories) do
    ParallelStream.map(categories, fn category ->
      offers = category.offers
      |> Enum.reduce(%{}, fn offer, map ->
        Map.put(map, "#{offer.title} #{offer.price}", offer)
      end)
      |> Enum.map(fn {_, offer} -> offer end)

      Map.put(category, :offers, offers)
    end)
  end

  # from rerank/rerank.js
  def remove_small_categories(categories) do
    threshold = Float.ceil(@min_cat_size * count_total_offers(categories))

    result = Enum.reject(categories, fn category ->
      length(category.offers) < threshold
    end)
  end

  def get_max_cat_price(category) do
    if category.offers == [] do
      0
    else
      most_expensive_offer = Enum.max_by(category.offers, fn offer ->
        offer.price
      end)
      most_expensive_offer.price
    end
  end

  def calculate_price_val(offer, max_cat_price) do
    1 - (offer.price / max_cat_price)
  end

  def add_price_val(offers, max_cat_price, calc_fn \\ &calculate_price_val/2) do
    Enum.map(offers, fn offer ->
      Map.put(offer, :price_val, calc_fn.(offer, max_cat_price))
    end)
  end

  def normalize_token_vals(categories, max_offer_token_val) do
    Enum.map(categories, fn category ->
      new_offers = Enum.map(category.offers, fn offer ->
        normalized_token_val = offer.token_val / max_offer_token_val;
        Map.put(offer, :token_val, normalized_token_val)
      end)
      Map.put(category, :offers, new_offers)
    end)
  end

  def add_prod_val(categories) do
    Enum.map(categories, fn category ->
      new_offers = Enum.map(category.offers, fn offer ->
        Map.put(offer, :val, 0.3 * offer.token_val + 0.7 * offer.price_val)
      end)
      Map.put(category, :offers, new_offers)
    end)
  end

  def add_category_token_vals(categories) do
    Enum.map(categories, fn category ->
      sum = Enum.reduce(category.offers, 0, fn offer, acc -> acc + offer.token_val end)

      num_offers = length(category.offers)
      cat_token_val = if num_offers == 0 do
        0
      else
        sum / length(category.offers)
      end

      Map.put(category, :token_val, cat_token_val)
    end)
  end

  def count_total_offers(categories) do
    offers_total = categories
    |> ParallelStream.map(fn category -> length(category.offers) end)
    |> Enum.sum
  end

  def add_cat_val(conn, categories) do
    num_offers = count_total_offers(categories)

    function = fn category ->
      if num_offers == 0 do
        0
      else
        cat_val = 0.5 * category.token_val + 0.5 * length(category.offers) / num_offers
      end

      Map.put(category, :val, cat_val)
    end

    categories
    |> Enum.map(&Task.async(fn ->
      try do
        function.(&1)
      rescue
        e in RuntimeError ->
          Apientry.ErrorReporter.report(conn, %{
            kind: :error,
            reason: e,
            stacktrace: System.stacktrace()
          })
      end
    end))
    |> Enum.map(&Task.await(&1))
  end

  def sort_categories(categories) do
    Enum.sort_by(categories, fn category -> category.val end, &>=/2)
  end

  def sort_products_within_categories(categories) do
    Enum.map(categories, fn category ->
      offers = Enum.sort_by(category.offers, fn offer -> offer.val end, &>=/2)
      Map.put(category, :offers, offers)
    end)
  end

  def normalize_num_offers(conn) do
    num = conn.params["numOffers"]
    
    if num == nil do
      10
    else
      {num, _} = Integer.parse(num)
      cond do
        num == nil ->
          10
        num > 50 ->
          50
        num < 1 ->
          10
        true ->
          num
      end
    end
  end

  def get_top_ten_offers(categories, conn) do
    num = normalize_num_offers(conn)
    Stream.flat_map(categories, fn category -> category.offers end)
    |> Enum.take(num)
  end

  def get_max_offer_token_val(categories) do
    token_vals = Stream.flat_map(categories, fn category ->
      Stream.map(category.offers, fn offer -> offer.token_val end)
    end)
    |> Enum.sort(&>=/2)
    
    if length(token_vals) > 0 do
      hd(token_vals)
    else
      0
    end
  end
end

require IEx

defmodule Apientry.Rerank do
  @min_cat_size 0.1

  @keywords_dont_stemm ~w(homme hommes femme femmes herren)

  @stemmers %{
    "us" => &Stemex.english/1,
    "au" =>  &Stemex.english/1,
    "gb" =>  &Stemex.english/1,
    "de" =>  &Stemex.german/1,
    "fr" =>  &Stemex.french/1
  }

  def get_products(conn, ebay_results, search_term, geo, fetched_url) do
    rerank1 = :os.system_time(:milli_seconds)
    geo = geo || "";

    regex_cache = Task.async(fn ->
      try do
        Apientry.Helpers.regex_strings(geo)
      rescue
        e in RuntimeError ->
          Apientry.ErrorReporter.report(conn, %{
            kind: :error,
            reason: e,
            stacktrace: System.stacktrace()
          })
      end
    end)

    categories = ebay_results

    time1 = :os.system_time(:milli_seconds)
    categories = format_ebay_results_for_rerank(categories)
    time2 = :os.system_time(:milli_seconds)
    format_ebay_results_for_rerank = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = remove_duplicate(categories)
    time2 = :os.system_time(:milli_seconds)
    remove_duplicate = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = remove_small_categories(categories)
    time2 = :os.system_time(:milli_seconds)
    remove_small_categories = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    
    regex_cache = Task.await(regex_cache)
    categories = Enum.map(categories, fn category ->
      regex_string = CsvCache.get(regex_cache, category.cat_id) || ""
      {:ok, regex} = regex_string |> Regex.compile()

      max_cat_price = get_max_cat_price(category)

      offers = category.offers
      offers = add_token_val(conn, offers, search_term, geo, regex, fetched_url)
      offers = add_price_val(offers, max_cat_price)

      Map.put(category, :offers, offers)
    end)
    time2 = :os.system_time(:milli_seconds)
    add_token_val_price_val = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    max_offer_token_val = get_max_offer_token_val(categories)
    time2 = :os.system_time(:milli_seconds)
    get_max_offer_token_val = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = normalize_token_vals(categories, max_offer_token_val)
    time2 = :os.system_time(:milli_seconds)
    normalize_token_vals = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = add_prod_val(categories)
    time2 = :os.system_time(:milli_seconds)
    add_prod_val = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = add_category_token_vals(categories)
    time2 = :os.system_time(:milli_seconds)
    add_category_token_vals = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = add_cat_val(conn, categories)
    time2 = :os.system_time(:milli_seconds)
    add_cat_val = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = sort_categories(categories)
    time2 = :os.system_time(:milli_seconds)
    sort_categories = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    categories = sort_products_within_categories(categories)
    time2 = :os.system_time(:milli_seconds)
    sort_products_within_categories = time2 - time1

    time1 = :os.system_time(:milli_seconds)
    result = get_top_ten_offers(categories, conn)
    |> Enum.map(fn offer -> offer.original_item end)
    time2 = :os.system_time(:milli_seconds)
    get_top_ten_offers = time2 - time1

    rerank2 = :os.system_time(:milli_seconds)
    rerank = rerank2 - rerank1

    time_data = %{
      format_ebay_results_for_rerank: format_ebay_results_for_rerank,
      remove_duplicate: remove_duplicate,
      remove_small_categories: remove_small_categories,
      add_token_val_price_val: add_token_val_price_val,
      get_max_offer_token_val: get_max_offer_token_val,
      normalize_token_vals: normalize_token_vals,
      add_prod_val: add_prod_val,
      add_category_token_vals: add_category_token_vals,
      add_cat_val: add_cat_val,
      sort_categories: sort_categories,
      sort_products_within_categories: sort_products_within_categories,
      get_top_ten_offers: get_top_ten_offers,
      rerank: rerank
    }

    Task.start(fn ->
      Apientry.Amplitude.track_latency(conn, time_data)
    end)

    result
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

  def normalize_string("") do
    ""
  end
  def normalize_string(string) do
    string
    |> String.downcase
    |> String.replace(~r/é/m, "e")
    |> String.replace(~r/(-|®|\||\(|\)|:|,|gen|’|_|\+|&|\!|\%|\*|\$|\@|\#|\;|\^|\/|'|\\|")/m, " ")
    |> String.replace(~r/ +(?= )/, "")
    |> String.trim()
  end

  def stem(string, stemer) do
    if Enum.any?(@keywords_dont_stemm, fn dont_stem -> string == dont_stem end) do
      string
    else
      stemer.(string)
    end
  end

  def tokenize(nil), do: []
  def tokenize(""), do: []
  def tokenize(string) do
    tokens = string
    |> normalize_string()
    |> String.split(~r/\s+/)
    |> Stream.filter(fn str -> String.length(str) > 1 end)
    |> Enum.reject(fn str -> str =~ ~r/^\d+$/ end)
  end
  def tokenize(string, geo) do
    string
    |> tokenize()
    |> Enum.map(fn str -> stem(str, @stemmers[geo]) end)
  end

  def get_attr_from_title_by_cat_id(geo, regex, title) do
    title = title
    |> tokenize(geo)
    |> Enum.join(" ")

    scanned = Regex.scan(regex, title) || []

    if length(scanned) > 1 do
      scanned
      |> Stream.map(fn element -> hd(element) end)
      |> Enum.reject(fn element -> element == "" end)
    else
      scanned
    end
  end

  def calculate_token_val(num_attr_search_term, num_same_tokens_between_title_and_search_term, num_tokens_in_searh_term) do
    result = (num_same_tokens_between_title_and_search_term / num_tokens_in_searh_term) * :math.pow(2, num_attr_search_term)

    result
  end

  def regex_from_list(list) do
    regex = Enum.join(list, "|")
    regex = "(#{regex})" 
    {:ok, regex} = Regex.compile(regex)
    regex
  end

  def get_num_of_attrs_name_contained_in_product([], geo, offer) do
    0
  end
  def get_num_of_attrs_name_contained_in_product(attributes_from_ebay, geo, offer) do
    tokenized_title = tokenize(offer.title, geo) |> Enum.join(" ")

    attributes_from_ebay
    |> regex_from_list()
    |> Regex.scan(tokenized_title)
    |> Stream.map(fn list -> hd(list) end)
    |> Stream.uniq()
    |> Enum.count
  end

  defp add_token_val_helper(offer, attributes_from_ebay, geo, search_term, token_count_in_search_term) do
    n = get_num_of_attrs_name_contained_in_product(attributes_from_ebay, geo, offer)
    m = get_num_of_same_tokens(offer, search_term)

    value = if token_count_in_search_term > 6 && m >= 5 do
      Map.put(offer, :token_val, 1 * :math.pow(2, m))
    else
      Map.put(offer, :token_val, calculate_token_val(n, m, token_count_in_search_term))
    end
  end

  def add_token_val(conn, offers, search_term, geo, regex, fetchedUrl) do
    token_count_in_search_term = length(tokenize(search_term))
    attributes_from_ebay = get_attr_from_title_by_cat_id(geo, regex, search_term)

    offers
    |> ParallelStream.filter(fn offer ->
      m = get_num_of_same_tokens(offer, search_term)

      (fetchedUrl && String.length(fetchedUrl) > 10 && fetchedUrl =~ ~r/(attributeValue|categoryId)/ && m >= 2) ||
      (token_count_in_search_term >= 10 && m > 5) ||
      (token_count_in_search_term > 5 && token_count_in_search_term <= 9 && m > 2) ||
      (token_count_in_search_term <= 5 && m > 1)
    end)
    |> ParallelStream.map(fn offer ->
      add_token_val_helper(offer, attributes_from_ebay, geo, search_term, token_count_in_search_term) 
    end)
    |> Enum.into([])
  end

  # counts the number of tokens in search term
  def get_num_of_same_tokens(offer, search_term) do
    title_tokens = Enum.uniq tokenize(offer.title)
    search_term_tokens = Enum.uniq tokenize(search_term)

    Enum.count(title_tokens, fn title_token ->
      Enum.any?(search_term_tokens, fn search_token ->
        search_token == title_token
      end)
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
    most_expensive_offer = Enum.max_by(category.offers, fn offer ->
      offer.price
    end)
    most_expensive_offer.price
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

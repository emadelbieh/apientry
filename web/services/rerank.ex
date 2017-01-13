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

  def get_products(ebay_results, search_term, geo, fetched_url) do
    geo = geo || "";

    categories = ebay_results
    |> format_ebay_results_for_rerank()
    |> remove_duplicate()
    |> remove_small_categories()

    categories = Enum.map(categories, fn category ->
      IO.puts "***********************************************"
      max_cat_price = get_max_cat_price(category)
      IO.puts "max_cat_price #{max_cat_price}"

      offers = category.offers
      IO.puts "-------------- with token vals ---------------"
      offers = add_token_val(offers, search_term, geo, category.cat_id, fetched_url)
      IO.inspect offers
      IO.puts "-------------- with price vals ---------------"
      offers = add_price_val(offers, max_cat_price)
      IO.inspect offers

      IO.puts "***********************************************"
      Map.put(category, :offers, offers)
    end)

    max_offer_token_val = get_max_offer_token_val(categories)
    categories = normalize_token_vals(categories, max_offer_token_val)
    categories = add_prod_val(categories)
    categories = add_category_token_vals(categories)
    categories = add_cat_val(categories)
    categories = sort_categories(categories)
    categories = sort_products_within_categories(categories)

    result = get_top_ten_offers(categories)
    |> Enum.map(fn offer -> offer.original_item end)

    IO.puts "============= result ==========================="
    IO.inspect(result)
    IO.puts "===============++++++++========================="

    result
  end

  # refactored from format_ebay_results_for_rerank
  def extract_offers(ebay_items) do
    ebay_items
    |> Enum.filter(fn item -> item["offer"] end)
    |> Enum.map(fn item ->
      {price, _} = Float.parse(item["offer"]["basePrice"]["value"])
      %{
        title: item["offer"]["name"],
        price: price,
        original_item: item
      }
    end)
  end

  def format_ebay_results_for_rerank(ebay_results) do
    ebay_results
    |> Enum.map(fn category ->
      %{
        cat_name: category["name"],
        cat_id: category["id"],
        offers: extract_offers(category["items"]["item"])
      }
    end)
  end

  def remove_duplicate(categories) do
    categories = Enum.map(categories, fn category ->
      offers = Enum.uniq_by(category.offers, fn offer ->
        "#{offer.title} #{offer.price}"
      end)
      category = Map.put(category, :offers, offers)
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

  def tokenize(string) do
    tokens = string
    |> normalize_string()
    |> String.split(~r/\s+/)
    |> Enum.reject(fn str -> str =~ ~r/\d+/ end)
  end

  def tokenize(string, geo) do
    result = string
    |> tokenize()
    |> Enum.map(fn str -> stem(str, @stemmers[geo]) end)

    result
  end

  def get_attr_from_title_by_cat_id(geo, cat_id, title) do
    if title =~ ~r/women/ do
      [ 'danskin', 'women', 'run', 'short' ] # danskin
    else
      ["nike", "men", "run"] # nike shoes
    end
  end

  def calculate_token_val(num_attr_search_term, num_same_tokens_between_title_and_search_term, num_tokens_in_searh_term) do
    num_same_tokens_between_title_and_search_term / num_tokens_in_searh_term * :math.pow(2, num_attr_search_term)
  end

  def regex_from_list(list) do
    regex = Enum.join(list, "|")
    regex = "(#{regex})" 
    {:ok, regex} = Regex.compile(regex)
    regex
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

  def add_token_val(offers, search_term, geo, cat_id, fetchedUrl) do
    token_count_in_search_term = length(tokenize(search_term))
    IO.puts "found #{token_count_in_search_term} tokens in search term"

    attributes_from_ebay = get_attr_from_title_by_cat_id(geo, cat_id, search_term)
    IO.puts "attributes_from_ebay:"
    IO.inspect attributes_from_ebay

    offers = Enum.filter(offers, fn offer ->
      m = get_num_of_same_tokens(offer, search_term)
      IO.puts "m: #{m}"

      qualified = (fetchedUrl && String.length(fetchedUrl) > 10 && fetchedUrl =~ ~r/(attributeValue|categoryId)/ && m >= 2) ||
      (token_count_in_search_term >= 10 && m > 5) ||
      (token_count_in_search_term > 5 && token_count_in_search_term <= 9 && m > 2) ||
      (token_count_in_search_term <= 5 && m > 1)
      
      IO.puts "qualified: #{qualified}"

      qualified
    end)
    IO.puts "&&&&&&&&&&&&&&&&&&&&&"

    offers = Enum.map(offers, fn offer ->
      n = get_num_of_attrs_name_contained_in_product(attributes_from_ebay, geo, offer)
      IO.puts "n: #{n}"
      m = get_num_of_same_tokens(offer, search_term)
      IO.puts "m: #{m}"
      IO.puts "token_count: #{token_count_in_search_term}"

      if token_count_in_search_term > 6 && m >= 5 do
        Map.put(offer, :token_val, 1 * :math.pow(2, m))
      else
        Map.put(offer, :token_val, calculate_token_val(n, m, token_count_in_search_term))
      end
    end)

    offers
  end

  # counts the number of tokens in search term
  def get_num_of_same_tokens(offer, search_term) do
    title_tokens = Enum.uniq tokenize(offer.title)
    IO.puts "title tokens:"
    IO.inspect title_tokens

    search_term_tokens = Enum.uniq tokenize(search_term)
    IO.puts "search_term tokens:"
    IO.inspect search_term_tokens

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
      cat_token_val = sum / length(category.offers)
      Map.put(category, :token_val, cat_token_val)
    end)
  end

  def count_total_offers(categories) do
    categories
    |> Stream.map(fn category -> length(category.offers) end)
    |> Enum.sum
  end

  def add_cat_val(categories) do
    num_offers = count_total_offers(categories)

    Enum.map(categories, fn category ->
      cat_val = 0.5 * category.token_val + 0.5 * length(category.offers) / num_offers
      Map.put(category, :val, cat_val)
    end)
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

  def get_top_ten_offers(categories) do
    Stream.flat_map(categories, fn category -> category.offers end)
    |> Enum.take(10)
  end

  def get_max_offer_token_val(categories) do
    Stream.flat_map(categories, fn category ->
      Stream.map(category.offers, fn offer -> offer.token_val end)
    end)
    |> Enum.sort(&>=/2)
    |> hd
  end
end

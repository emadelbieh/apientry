defmodule Apientry.TitleWeightService do
  @keywords_dont_stemm ~w(homme hommes femme femmes herren)

  @stemmers %{
    "us" => &Stemex.english/1,
    "au" =>  &Stemex.english/1,
    "gb" =>  &Stemex.english/1,
    "de" =>  &Stemex.german/1,
    "fr" =>  &Stemex.french/1
  }

  def apply_title_weights() do
  end

  def prepare_regex_cache(conn, geo) do
    Task.async(fn ->
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
  end

  def apply_weights(conn, ebay_results, search_term, geo, fetched_url, regex_cache, categories) do
    regex_cache = Task.await(regex_cache)

    categories = Enum.map(categories, fn category ->
      regex_string = CsvCache.get(regex_cache, category.cat_id) || ""
      {:ok, regex} = regex_string |> Regex.compile()

      offers = category.offers
      offers = add_token_val(conn, offers, search_term, geo, regex, fetched_url)

      Map.put(category, :offers, offers)
    end)
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

  defp add_token_val_helper(offer, attributes_from_ebay, geo, search_term, token_count_in_search_term) do
    n = get_num_of_attrs_name_contained_in_product(attributes_from_ebay, geo, offer)
    m = get_num_of_same_tokens(offer, search_term)

    value = if token_count_in_search_term > 6 && m >= 5 do
      Map.put(offer, :token_val, 1 * :math.pow(2, m))
    else
      Map.put(offer, :token_val, calculate_token_val(n, m, token_count_in_search_term))
    end
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

  def calculate_token_val(num_attr_search_term, num_same_tokens_between_title_and_search_term, num_tokens_in_searh_term) do
    result = (num_same_tokens_between_title_and_search_term / num_tokens_in_searh_term) * :math.pow(2, num_attr_search_term)

    result
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

  def regex_from_list(list) do
    regex = Enum.join(list, "|")
    regex = "(#{regex})" 
    {:ok, regex} = Regex.compile(regex)
    regex
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
end

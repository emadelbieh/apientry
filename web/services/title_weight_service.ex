defmodule Apientry.TitleWeightService do
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

  def apply_weights(conn, ebay_results, search_term, geo, fetched_url, regex_cache) do
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
end

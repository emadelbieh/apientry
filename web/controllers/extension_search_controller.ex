defmodule Apientry.ExtensionSearchController do
  use Apientry.Web, :controller

  @default_endpoint "GeneralSearch"

  alias Apientry.StringKeyword
  alias Apientry.Searcher

  import Apientry.ParameterValidators, only: [validate_keyword: 2, reject_search_engines: 2]

  plug :put_view, Apientry.SearchView
  plug :validate_keyword
  plug :clean_keyword
  plug :assign_override_price_flag
  plug :assign_num_items_flag
  plug :check_price
  plug :reject_search_engines
  plug Apientry.SubidLookupPlug
  plug :set_search_options


  def search(conn, params) do
    assigns = conn.assigns
    assigns = Map.put(assigns, :format_for_extension, true)
    conn = Map.put(conn, :assigns, assigns)
    Apientry.SearchController.search_rerank(conn, params)
  end

  defp add_num_items(string_keyword, conn) do
    if conn.assigns[:set_num_items?] do
      string_keyword
      |> StringKeyword.put("numItems", 25)
    else
      string_keyword
    end
  end

  defp add_price_details(string_keyword, conn) do
    if conn.assigns[:should_override_price] do
      string_keyword
      |> StringKeyword.delete("price")
      |> StringKeyword.put("minPrice", conn.assigns.minPrice)
      |> StringKeyword.put("maxPrice", conn.assigns.maxPrice)
    else
      string_keyword
    end
  end

  defp clean_keyword(conn, _opts) do
    keyword = conn.params["keyword"]
    cleaned = Apientry.TitleCleaner.clean(keyword)

    conn
    |> assign(:cleaned_keyword, cleaned)
  end

  defp assign_override_price_flag(conn, _) do
    conn
    |> assign(:should_override_price, true)
  end

  defp assign_num_items_flag(conn, _opts) do
    conn
    |> assign(:set_num_items?, true)
  end

  defp check_price(%{params: %{"minPrice" => min, "maxPrice" => max}} = conn, _) do
    conn
    |> assign(:minPrice, min)
    |> assign(:maxPrice, max)
  end

  defp check_price(%{params:  %{"price" => price}} = conn, _) do
    [min, max] = price |> Apientry.PriceCleaner.clean()
                  |> Apientry.PriceGenerator.get_min_max()

    conn
    |> assign(:minPrice, min)
    |> assign(:maxPrice, max)
  end

  defp check_price(conn, _opts) do
    conn
    |> assign(:valid, false)
    |> render(:error, data: %{error: "invalid price"})
    |> halt()
  end

  def replace_keyword_with_cleaned(string_keyword, conn) do
    if conn.assigns[:cleaned_keyword] do
      string_keyword
      |> StringKeyword.put("keyword", conn.assigns.cleaned_keyword)
    else
      string_keyword
    end
  end

  @doc """
  Sets search options to be picked up by `search/2` (et al).
  Done so that you have the same stuff in `/publisher` and `/dryrun/publisher`.
  """
  def set_search_options(%{query_string: query_string} = conn, _) do
    params = query_string
    |> StringKeyword.from_query_string()
    |> add_price_details(conn)
    |> add_num_items(conn)
    |> replace_keyword_with_cleaned(conn)

    params = Enum.into(params, %{})

    params = if params["visitorUserAgent"] do
      params
    else
      req_headers = conn.req_headers |> Enum.into(%{})
      Map.put(params, "visitorUserAgent", req_headers["user-agent"])
    end

    params = if params["visitorIPAddress"] do
      params
    else
      req_headers = conn.req_headers |> Enum.into(%{})

      direct_ip = case conn.remote_ip do
        {a,b,c,d} -> "#{a}.#{b}.#{c}.#{d}"
        _ -> nil
      end

      ip = req_headers["cf-connecting-ip"] || direct_ip
      Map.put(params, "visitorIPAddress", ip)
    end

    params = Map.merge(params, conn.params)

    conn = Map.put(conn, :params, params)
    format = get_format(conn)
    endpoint = conn.params["endpoint"] || @default_endpoint

    result = Searcher.search(format, endpoint, params, conn)

    result
    |> Enum.reduce(conn, fn {key, val}, conn -> assign(conn, key, val) end)
  end

  def set_search_options(conn, _) do
    conn
    |> assign(:valid, false)
  end
end

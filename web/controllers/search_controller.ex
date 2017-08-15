require IEx

defmodule Apientry.SearchController do
  @moduledoc """
  Takes in requests from /publisher.

      GET /publisher?keyword=nikon
  """

  @default_endpoint "GeneralSearch"

  use Apientry.Web, :controller

  alias HTTPoison.Response
  alias Apientry.Searcher
  alias Apientry.EbayTransformer
  alias Apientry.ErrorReporter
  alias Apientry.StringKeyword
  alias Apientry.HTTP

  import Apientry.ParameterValidators, only: [validate_keyword: 2, reject_search_engines: 2]

  plug :validate_keyword when action in [:search, :search_rerank, :search_rerank_coupons]
  plug :reject_search_engines when action in [:search, :search_rerank, :search_rerank_coupons]
  plug :set_search_options when action in [:search, :dry_search, :search_rerank, :search_rerank_coupons]

  @doc """
  Dry run of a search.

      GET /dryrun/publisher?keyword=nikon
  """
  def dry_search(%{assigns: assigns} = conn, _) do
    conn
    |> json(assigns)
  end

  def get_exceptions(body) do
    body["exceptions"] && body["exceptions"]["exception"]
  end

  def get_errors(body) do
    case get_exceptions(body) do
      nil -> []
      errors ->
        errors
        |> Enum.filter(&(&1["type"] == "error"))
    end
  end


  @doc """
  Takes in requests from /publisher.

      GET /publisher?keyword=nikon
  """
  def search(%{assigns: %{url: url, format: format}} = conn, %{"categoryId" => category_id, "keyword" => keyword} = params) do
    case HTTP.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        body = Poison.decode!(body)
        ErrorReporter.track_ebay_response(conn, status, body, headers)

        request_format = conn.params["format"] || "json"

        categories =
          body["categories"]["category"]
          |> Apientry.Rerank.format_ebay_results_for_rerank()

        req_url = "http://api.apientry.com/publisher?#{conn.query_string}"
        
        geo = conn.assigns.country |> String.downcase
        regex_cache = Apientry.TitleWeightService.prepare_regex_cache(conn, geo)
        categories = Apientry.TitleWeightService.apply_weights(conn, categories, req_url, regex_cache)
        IEx.pry



              decoded = Poison.decode!(body)
              kw = conn.query_params["keyword"]

              new_data = Apientry.Rerank.get_products(conn, decoded["categories"]["category"], kw, geo, req_url)

        track_publisher(conn)

        conn
        |> put_status(status)
        |> put_resp_content_type("application/#{request_format}")
        |> render("index.xml", data: body)

      {:error, %HTTPoison.Error{reason: reason} = error} ->
        ErrorReporter.track_httpoison_error(conn, error)
        conn
        |> put_status(400)
        |> render(:error, data: %{error: reason})
    end
  end

  def search(%{assigns: %{url: url, format: format}} = conn, _) do
    case HTTP.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        body = Poison.decode!(body)
        ErrorReporter.track_ebay_response(conn, status, body, headers)

        request_format = conn.params["format"] || "json"

        body = cond do
          length(get_errors(body)) > 0  ->
            transform_by_format(conn, body, request_format)
            |> Poison.encode!()
          conn.params["endpoint"] && conn.params["endpoint"] =~ ~r/categorytree/i ->
            transform_by_format(conn, body, request_format)
            |> Poison.encode!()
          true ->
            transform_by_format(conn, body, request_format)
            |> Apientry.TitleFilter.remove_sizes_and_colors()
            |> Apientry.TitleFilter.filter_duplicate_title()
            |> Poison.encode!()
        end

        track_publisher(conn)

        conn
        |> put_status(status)
        |> put_resp_content_type("application/#{request_format}")
        |> render("index.xml", data: body)

      {:error, %HTTPoison.Error{reason: reason} = error} ->
        ErrorReporter.track_httpoison_error(conn, error)
        conn
        |> put_status(400)
        |> render(:error, data: %{error: reason})
    end
  end

  def search(%{assigns: %{error: error, details: details}} = conn, _) do
    conn
    |> put_status(400)
    |> render(:error, data: %{error: error, details: details})
  end

  def search(conn, _) do
    conn
    |> put_status(400)
    |> render(:error, data: %{error: :unknown_error})
  end


  defp build_category_chooser_data(conn) do
    country = conn.assigns.country |> String.downcase

    %{
      "geo" => country,
      "kw" => conn.params["keyword"],
    }
  end

  def append_category_data(url, %{attribute_values: []}), do: url
  def append_category_data(url, category_data) do
    url = url <> "&categoryId=#{category_data[:category_id]}"
    Enum.reduce(category_data[:attribute_values], url, fn attr, url ->
      url <> "&attributeValue=#{attr}"
    end)
  end

  def add_min_max_price(params) do
    max_price = params["maxPrice"] || "1000000"
    min_price = params["minPrice"] || "0"

    params
    |> Map.put("minPrice", min_price)
    |> Map.put("maxPrice", max_price)
  end

  def search_rerank_coupons(conn, params) do
    assigns = conn.assigns
    assigns = Map.put(assigns, :include_coupons, true)
    conn = Map.put(conn, :assigns, assigns)
    search_rerank(conn, params)
  end

  def search_rerank(%{assigns: %{url: url, format: format}} = conn, params) do
    conn = Map.put(conn, :params, add_min_max_price(conn.params))

    # run category chooser
    category_data = conn
                    |> build_category_chooser_data()
                    |> Apientry.CategoryChooser.init()
                    |> Apientry.CategoryChooser.get_category_data()

    url = append_category_data(url, category_data)

    # run first fetch
    first_fetch = nil
    second_fetch = nil
    remote_catchooser = nil
    rerank = nil

    case HTTP.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        body = Poison.decode!(body)

        if length(category_data[:attribute_values]) == 0 &&
          body["categories"] && body["categories"]["category"]  &&
          length(body["categories"]["category"]) == 1 do

          category = hd(body["categories"]["category"])
          category_id = if (category["id"] in ["0", "", nil]), do: "", else: category["id"]
          cat_data = Apientry.StrongAttributeIDSelector.get_strong_attr_ids(%{
            "category_id" => category_id,
            "geo"         => String.downcase(conn.assigns.country),
            "kw"          => conn.params["keyword"]
          })

          url = url <> "&" <> URI.encode_query(cat_data)

          second_fetch_1 = :os.system_time
          result = case HTTP.get(url) do
            {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
              body = Poison.decode!(body)
              ErrorReporter.track_ebay_response(conn, status, body, headers)

              request_format = conn.params["format"] || "json"
              body = transform_by_format(conn, body, request_format)
              |> Apientry.TitleFilter.remove_sizes_and_colors()
              |> Poison.encode!()

              track_publisher(conn)

              decoded = Poison.decode!(body)
              geo = conn.assigns.country |> String.downcase
              kw = conn.query_params["keyword"]
              req_url = "http://api.apientry.com/publisher?#{conn.query_string}"

              new_data = Apientry.Rerank.get_products(conn, decoded["categories"]["category"], kw, geo, req_url)

              items = hd(decoded["categories"]["category"])
              items = put_in(items, ["items","item"], new_data)
              decoded = put_in(decoded, ["categories", "category"], [items])

              resp = if conn.assigns[:include_coupons] do
                Map.merge(decoded, %{coupons: Apientry.Coupon.to_map(Apientry.Coupon.by_params(conn))})
              else
                decoded
              end

              resp = if conn.assigns[:format_for_extension] do
                format_data_for_extension(decoded, params["price"])
              else
                decoded
              end

              conn
              |> put_status(status)
              |> put_resp_content_type("application/#{request_format}")
              |> render("index.xml", data: Poison.encode!(resp))

            {:error, %HTTPoison.Error{reason: reason} = error} ->
              ErrorReporter.track_httpoison_error(conn, error)
              conn
              |> put_status(400)
              |> render(:error, data: %{error: reason})
          end
          result
        else
          ErrorReporter.track_ebay_response(conn, status, body, headers)

          request_format = conn.params["format"] || "json"
          body = transform_by_format(conn, body, request_format)
                 |> Apientry.TitleFilter.remove_sizes_and_colors()
                 |> Poison.encode!()

          track_publisher(conn)

          decoded = Poison.decode!(body)
          geo = conn.assigns.country |> String.downcase
          kw = conn.query_params["keyword"]
          req_url = "http://api.apientry.com/publisher?#{conn.query_string}"

          new_data = Apientry.Rerank.get_products(conn, decoded["categories"]["category"], kw, geo, req_url)

          if length(decoded["categories"]["category"]) > 0 do
            items = hd(decoded["categories"]["category"])
            items = put_in(items, ["items","item"], new_data)
            decoded = put_in(decoded, ["categories", "category"], [items])
          end

          resp = if conn.assigns[:include_coupons] do
            Map.merge(decoded, %{coupons: Apientry.Coupon.to_map(Apientry.Coupon.by_params(conn))})
          else
            decoded
          end

          resp = if conn.assigns[:format_for_extension] do
            format_data_for_extension(decoded, params["price"])
          else
            decoded
          end

          conn
          |> put_status(status)
          |> put_resp_content_type("application/#{request_format}")
          |> render("index.xml", data: Poison.encode!(resp))
        end
      {:error, %HTTPoison.Error{reason: reason} = error} ->
        ErrorReporter.track_httpoison_error(conn, error)
        conn
        |> put_status(400)
        |> render(:error, data: %{error: reason})
    end
  end

  defp format_data_for_extension(body, original_price) do
    result = Enum.flat_map(body["categories"]["category"], fn category ->
      Enum.map(category["items"]["item"], fn item ->
        offer = item["offer"]
        %{
          item_url: offer["offerURL"],
          item_id: "",
          item_title: offer["name"],
          item_price: offer["basePrice"]["value"],
          item_currency_code: offer["basePrice"]["currency"],
          item_image: hd(offer["imageList"]["image"])["sourceURL"],
          is_free_shipping: is_free_shipping(offer),
          store_name: offer["store"]["name"],
          pub_advert_subid: 9,
          api_used: "ebay",
          offer_id: offer["id"],
          cpc: offer["cpc"],
          store_logo: offer["store"]["logo"]["sourceURL"]
        }
      end)
    end)

    %{
      success: true,
      info: %{
        items: result
      }
    }
  end

  defp get_product_image(product) do
    hd(product["imageList"]["image"])["sourceURL"]
  end

  defp is_free_shipping(product) do
    product["shipping_cost"]["value"] == "0.00"
  end

  defp calculate_savings(price, original_price) do
    {price, _} = Float.parse(price)
    {original_price, _} = Float.parse(original_price)

    if price < original_price do
      percentage = 100 - (price / original_price * 100)
      "#{percentage}%"
    else
      ""
    end
  end

  defp transform_by_format(conn, body, format) do
    case format do
      "json" ->
        body
        |> EbayTransformer.transform(conn.assigns, format)
      "xml" ->
        body = body
        |> EbayTransformer.transform(conn.assigns, format)
        |> XmlBuilder.generate
        "<?xml version='1.0' encoding='UTF-8' ?>\n" <> body
    end
  end

  @doc """
  Sets search options to be picked up by `search/2` (et al).
  Done so that you have the same stuff in `/publisher` and `/dryrun/publisher`.
  """
  def set_search_options(%{query_string: query_string} = conn, _) do
    params = query_string
    |> StringKeyword.from_query_string()

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

  defp track_publisher(conn) do
    if get_req_header(conn, "x-apientry-dnt") == [] do
      Task.start fn ->
        Apientry.Amplitude.track_publisher(conn.assigns)
        Apientry.Analytics.track_publisher(conn, conn.assigns)
      end
    end
  end
end

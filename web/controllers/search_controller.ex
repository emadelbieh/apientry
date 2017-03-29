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

  plug :set_search_options when action in [:search, :dry_search, :search_rerank, :search_rerank_coupons, :extension_search]

  @doc """
  Dry run of a search.

      GET /dryrun/publisher?keyword=nikon
  """
  def dry_search(%{assigns: assigns} = conn, _) do
    conn
    |> json(assigns)
  end

  @doc """
  Takes in requests from /publisher.

      GET /publisher?keyword=nikon
  """
  def search(%{assigns: %{url: url, format: format}} = conn, _) do
    time1 = :os.system_time
    result = case HTTPoison.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        body = Poison.decode!(body)
        ErrorReporter.track_ebay_response(conn, status, body, headers)

        request_format = conn.params["format"] || "json"
        body = transform_by_format(conn, body, request_format)

        if get_req_header(conn, "x-apientry-dnt") == [] do
          Apientry.Amplitude.track_publisher(conn.assigns)
        end

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
    time2 = :os.system_time
    IO.puts "#{time2 - time1} without rerank"
    result
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
    overall_1 = :os.system_time

    conn = Map.put(conn, :params, add_min_max_price(conn.params))

    # run category chooser
    time1 = :os.system_time
    category_data = conn
                    |> build_category_chooser_data()
                    |> Apientry.CategoryChooser.init()
                    |> Apientry.CategoryChooser.get_category_data()

    url = append_category_data(url, category_data)

    time2 = :os.system_time
    local_catchooser = time2 - time1


    # run first fetch
    first_fetch_1 = :os.system_time
    first_fetch = nil
    second_fetch = nil
    remote_catchooser = nil
    rerank = nil

    result = case HTTPoison.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        first_fetch_2 = :os.system_time
        first_fetch = first_fetch_2 - first_fetch_1

        body = Poison.decode!(body)

        if length(category_data[:attribute_values]) == 0 &&
          body["categories"] && body["categories"]["category"]  &&
          length(body["categories"]["category"]) == 1 do

          time1 = :os.system_time

          category = hd(body["categories"]["category"])
          category_id = if (category["id"] in ["0", "", nil]), do: "", else: category["id"]
          cat_data = Apientry.StrongAttributeIDSelector.get_strong_attr_ids(%{
            "category_id" => category_id,
            "geo"         => String.downcase(conn.assigns.country),
            "kw"          => conn.params["keyword"]
          })

          url = url <> "&" <> URI.encode_query(cat_data)

          IO.puts "**********************"
          IO.puts URI.encode_query(cat_data)
          IO.puts "**********************"
          time2 = :os.system_time
          remote_catchooser = time2 - time1

          time1 = :os.system_time
          second_fetch_1 = :os.system_time
          result = case HTTPoison.get(url) do
            {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
              second_fetch_2 = :os.system_time
              second_fetch = second_fetch_2 - second_fetch_1

              body = Poison.decode!(body)
              ErrorReporter.track_ebay_response(conn, status, body, headers)

              request_format = conn.params["format"] || "json"
              body = transform_by_format(conn, body, request_format)

              if get_req_header(conn, "x-apientry-dnt") == [] do
                Apientry.Amplitude.track_publisher(conn.assigns)
              end

              decoded = Poison.decode!(body)
              geo = conn.assigns.country |> String.downcase
              kw = conn.query_params["keyword"]
              req_url = "http://api.apientry.com/publisher?#{conn.query_string}" 

              time1 = :os.system_time
              new_data = Apientry.Rerank.get_products(conn, decoded["categories"]["category"], kw, geo, req_url)
              time2 = :os.system_time
              rerank = time2 - time1

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

          if get_req_header(conn, "x-apientry-dnt") == [] do
            Apientry.Amplitude.track_publisher(conn.assigns)
          end

          decoded = Poison.decode!(body)
          geo = conn.assigns.country |> String.downcase
          kw = conn.query_params["keyword"]
          req_url = "http://api.apientry.com/publisher?#{conn.query_string}" 

          time1 = :os.system_time
          new_data = Apientry.Rerank.get_products(conn, decoded["categories"]["category"], kw, geo, req_url)
          time2 = :os.system_time
          rerank = time2 - time1

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
    overall_2 = :os.system_time
    overall = overall_2 - overall_1

    IO.puts "**************** time results ****************"
    IO.puts "local catchooser: #{local_catchooser}"
    IO.puts "remote_catchooser: #{remote_catchooser}"
    IO.puts "ebay first fetch: #{first_fetch}"
    IO.puts "ebay second_fetch: #{second_fetch}"
    IO.puts "rerank: #{rerank}"
    IO.puts "overall: #{overall}"
    IO.puts "**************** time results ****************"


    Task.start(fn ->
      Apientry.Amplitude.track_latency(conn, %{
        "local_catchooser" => local_catchooser,
        "remote_catchooser" => remote_catchooser,
        "ebay_first_fetch" => first_fetch,
        "ebay_second_fetch" => second_fetch,
        "rerank" => rerank,
        "overall" => overall
      }, "overall")
    end)

    result
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
        |> Poison.encode!()
      "xml" ->
        body = body
        |> EbayTransformer.transform(conn.assigns, format)
        |> XmlBuilder.generate
        "<?xml version='1.0' encoding='UTF-8' ?>\n" <> body
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

  def extension_search(conn, params) do
    assigns = conn.assigns
    assigns = Map.put(assigns, :format_for_extension, true)
    conn = Map.put(conn, :assigns, assigns)
    search_rerank(conn, params)
  end

  defp format_price(value) do
    price = String.downcase(value)

    price = if String.match?(price, ~r/(eur|gbp|£|€)/) do
      price = String.replace(price, ~r/\./, "")
      price = Regex.run(~r/\d+,{0,1}\d+/, price)
      price = Enum.map(price, fn price -> String.replace(price, ~r/,/, ".") end)
    else
      price = String.replace(price, ~r/,/, "")
      price = Regex.run(~r/\d+\.{0,1}\d+/, price)
    end

    if length(price) > 0 do
      hd(price)
    else
      price
    end
  end


  @doc """
  Sets search options to be picked up by `search/2` (et al).
  Done so that you have the same stuff in `/publisher` and `/dryrun/publisher`.
  """
  def set_search_options(%{query_string: query_string} = conn, _) do
    if search_engine?(conn) do
      conn
      |> assign(:valid, false)
      |> render(:error, data: %{error: "Search Engine"})
      |> halt()
    else
      params = query_string
      |> StringKeyword.from_query_string()

      params = Enum.map(params, fn {key, value} ->
        if key == "price" do
          {"price", format_price(value)}
        else
          {key, value}
        end
      end)

      params = Enum.into(params, %{})
      conn = Map.put(conn, :params, params)

      format = get_format(conn)
      endpoint = conn.params["endpoint"] || @default_endpoint
      result = Searcher.search(format, endpoint, params, conn)

      result
      |> Enum.reduce(conn, fn {key, val}, conn -> assign(conn, key, val) end)
    end
  end

  def set_search_options(conn, _) do
    conn
    |> assign(:valid, false)
  end

  defp search_engine?(conn) do
    Enum.any?(["yahoo", "google", "bing"], fn engine ->
      conn.params["domain"] =~ engine
    end)
  end
end

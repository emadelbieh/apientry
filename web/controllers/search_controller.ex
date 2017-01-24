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

  plug :set_search_options when action in [:search, :dry_search, :search_rerank]

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

  def search_rerank(%{assigns: %{url: url, format: format}} = conn, _) do
    cat_data = CatChooser.get()

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

        decoded = Poison.decode!(body)
        geo = conn.assigns.country |> String.downcase
        kw = conn.query_params["keyword"]
        req_url = "http://api.apientry.com/publisher?#{conn.query_string}" 

        time1 = :os.system_time
        new_data = Apientry.Rerank.get_products(conn, decoded["categories"]["category"], kw, geo, req_url)
        time2 = :os.system_time
        IO.puts "get_products took #{time2 - time1} nanoseconds"

        items = hd(decoded["categories"]["category"])
        items = put_in(items, ["items","item"], new_data)
        decoded = put_in(decoded, ["categories", "category"], [items])

        conn
        |> put_status(status)
        |> put_resp_content_type("application/#{request_format}")
        |> render("index.xml", data: Poison.encode!(decoded))

      {:error, %HTTPoison.Error{reason: reason} = error} ->
        ErrorReporter.track_httpoison_error(conn, error)
        conn
        |> put_status(400)
        |> render(:error, data: %{error: reason})
    end
    result
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

  def direct(conn, _) do
    url = "http://api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?apiKey=b975ebbe-e61b-4044-a993-9093f2d10c71&keyword=nikon&visitorUserAgent=Mozilla+OSX&trackingId=8095836"
    case HTTPoison.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        conn
        |> put_status(status)
        |> text("test")
      {:error, _} ->
        conn
        |> put_status(400)
        |> text("test")
    end
  end
end

defmodule Apientry.SearchController do
  @moduledoc """
  Takes in requests from /publisher.

      GET /publisher?keyword=nikon
  """

  use Apientry.Web, :controller

  alias HTTPoison.Response
  alias Apientry.Searcher
  alias Apientry.EbayTransformer
  alias Apientry.ErrorReporter
  alias Apientry.StringKeyword

  plug :set_search_options when action in [:search, :dry_search]

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
    case HTTPoison.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        body = Poison.decode!(body)
        Task.start(fn ->
          Apientry.ImageTracker.track_images(conn, body)
        end)
        ErrorReporter.track_ebay_response(conn, status, body, headers)

        headers = Enum.into(headers, %{}) # convert to map
        body = body
        |> EbayTransformer.transform(conn.assigns, format)
        |> Poison.encode!()

        if get_req_header(conn, "x-apientry-dnt") == [] do
          Apientry.Amplitude.track_publisher(conn.assigns)
        end

        conn
        |> put_status(status)
        |> put_resp_content_type(headers["Content-Type"])
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

  @doc """
  Sets search options to be picked up by `search/2` (et al).
  Done so that you have the same stuff in `/publisher` and `/dryrun/publisher`.
  """
  def set_search_options(%{query_string: query_string} = conn, _) do
    params = query_string
    |> StringKeyword.from_query_string()
    |> StringKeyword.put("endpoint", conn.params["endpoint"])

    format = get_format(conn)
    result = Searcher.search(format, params, conn)

    result
    |> Enum.reduce(conn, fn {key, val}, conn -> assign(conn, key, val) end)
  end

  def set_search_options(conn, _) do
    conn
    |> assign(:valid, false)
  end
end

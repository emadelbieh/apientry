defmodule Apientry.SearchController do
  @moduledoc """
  Takes in requests from /publisher.

      GET /publisher?keyword=nikon
  """

  use Apientry.Web, :controller

  alias HTTPoison.Response

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
  def search(%{assigns: %{url: url}} = conn, _) do
    case HTTPoison.get(url) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        headers = Enum.into(headers, %{}) # convert to map
        conn
        |> put_status(status)
        |> put_resp_content_type(headers["Content-Type"])
        |> render("index.xml", data: body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(500)
        |> render(:error, data: %{message: reason})
    end
  end

  @doc """
  Handles searches that don't pass validation (no keywords).

      GET /publisher
      HTTP 500 Internal Server Error
      { "message": "Invalid request" }
  """
  def search(conn, _) do
    conn
    |> put_status(500)
    |> render(:error, data: %{message: "Invalid request"})
  end

  @doc """
  Sets search options to be picked up by `search/2` (et al).
  Done so that you have the same stuff in `/publisher` and `/dryrun/publisher`.
  """
  def set_search_options(%{params: %{"keyword" => _} = params} = conn, _) do
    format = get_format(conn)
    url = EbaySearch.search(format, params)
    country = IpLookup.lookup(params["visitorIPAddress"])

    conn
    |> assign(:valid, true)
    |> assign(:format, format)
    |> assign(:country, country)
    |> assign(:url, url)
  end

  def set_search_options(conn, _) do
    conn
    |> assign(:valid, false)
  end
end

defmodule Apientry.SearchController do
  @moduledoc """
  Takes in requests from /publisher.

      GET /publisher?keyword=nikon
  """

  use Apientry.Web, :controller

  alias HTTPoison.Response

  @doc """
  Takes in requests from /publisher.

      GET /publisher?keyword=nikon
  """
  def search(conn, %{ "keyword" => keyword }) do
    url = EbaySearch.search(keyword: keyword)

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
        |> render("error.json", data: %{ message: reason })
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
    |> render("error.json", data: %{ message: "Invalid request" })
  end
end

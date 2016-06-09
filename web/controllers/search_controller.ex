defmodule Apientry.SearchController do
  use Apientry.Web, :controller

  alias HTTPoison.Response

  def search(conn, %{ "keyword" => keyword }) do
    url = EbaySearch.search(keyword: keyword)

    case HTTPoison.get(url) do
      {:ok,  %Response{status_code: status, body: body}} ->
        conn
        |> put_status(status)
        |> render("index.xml", data: body)
      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(500)
        |> render("error.json", data: %{ reason: reason })
    end
  end

  def search(conn, _) do
    conn
    |> put_status(500)
    |> render("error.json", data: %{ reason: "Invalid request" })
  end
end

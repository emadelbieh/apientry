defmodule Apientry.RedirectController do
  @moduledoc """
  Works the `/redirect/` path.

  The Redirect endpoint receives a Base64 fragment like so:

      http://sandbox.apientry.com/redirect/P2xpbms9aHR0cDovL2dvb2dsZS5jb20=

  Decoding this fragment will return `?` and a query string fragment:

      pry> Base.decode64("P2xpbms9aHR0cDovL2dvb2dsZS5jb20=")
      "?link=http://google.com"
  """

  use Apientry.Web, :controller

  def show(conn, %{"fragment" => fragment} = _params) do
    with \
      {:ok, decoded_fragment} <- decode_base64(fragment),
      {:ok, query_string} <- strip_question_mark(decoded_fragment),
      {:ok, map} <- decode_query(query_string),
      {:ok, url} <- extract_link(map)
    do
      conn
      |> redirect(external: url)
    else
      {:error, err, details} ->
        conn
        |> put_status(400) # bad request
        |> json(%{ "error": err, "details": details })
      _ ->
        conn
        |> put_status(400) # bad request
        |> json(%{ "error": "Invalid request", "details": %{} })
    end
  end

  defp decode_base64(fragment) do
    case Base.decode64(fragment) do
      {:ok, decoded} -> {:ok, decoded}
      _ -> {:error, :invalid_base64, %{}}
    end
  end

  def strip_question_mark(fragment) do
    case fragment do
      "?" <> query_string -> {:ok, query_string}
      _ -> {:error, :no_question_mark, %{}}
    end
  end

  def decode_query(query_string) do
    try do
      {:ok, URI.decode_query(query_string)}
    rescue
      _ -> {:error, :invalid_query_string, %{}}
    end
  end

  def extract_link(%{"link" => url}) do
    {:ok, url}
  end

  def extract_link(_) do
    {:error, :no_link, %{}}
  end
end

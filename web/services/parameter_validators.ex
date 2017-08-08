defmodule Apientry.ParameterValidators do
  @moduledoc """
  A set of validators for validating the parameters sent to the api.
  """

  import Phoenix.Controller

  @invalid_keywords ["", "null", nil]
  @search_engines   ["ask.com", "yahoo", "google", "bing"]

  @doc """
  A plug that checks for the presence of a keyword. If none is found, we halt the connection
  """
  def validate_keyword(conn, _opts) do
    cond do
      conn.params["endpoint"] =~ ~r/categorytree/i ->
        conn
      conn.params["productId"] ->
        conn
      conn.params["keyword"] in @invalid_keywords ->
        conn
        |> assign(:valid, false)
        |> render(:error, data: %{error: "invalid keyword"})
        |> halt()
      true ->
        conn
    end
  end

  @doc """
  A plug that checks whether request is coming from search engines.
  """
  def reject_search_engines(conn, _opts) do
    domain = conn.params["domain"] || ""
    case @search_engines |> Enum.any?(&(domain =~ &1)) do
      true ->
        conn
        |> assign(:valid, false)
        |> render(:error, data: %{error: "domain is invalid"})
        |> halt()
      false ->
        conn
    end
  end

  defp assign(conn, key, value) do
    Plug.Conn.assign(conn, key, value)
  end

  defp halt(conn) do
    Plug.Conn.halt(conn)
  end
end

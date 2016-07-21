defmodule Apientry.ErrorReporter do
  @moduledoc """
  Reports errors.
  """

  @doc """
  Reports an error to `Rollbax.report`, but adds data from `conn` and `custom_data`.

      ErrorReporter.report(conn, %{
        kind: :error,
        reason: error,
        stacktrace: System.stacktrace()
      }, %{
        fingerprint: "0a193behuc8"
      })

  For a reference of what `custom_data` can have, see:

  - https://rollbar.com/docs/api/items_post/
  """
  def report(conn, %{kind: kind, reason: reason, stack: stacktrace}, custom_data \\ %{}) do
    conn = conn
    |> Plug.Conn.fetch_cookies()
    |> Plug.Conn.fetch_query_params()
    |> Plug.Conn.fetch_session()

    # Based on https://hexdocs.pm/rollbax/using-rollbax-in-plug-based-applications.html
    # This is a weird naive deep_merge implementation
    conn_data = Map.merge(custom_data, %{
      code_version: to_string(Application.spec(:apientry, :vsn)),
      request: Map.merge(%{
        cookies: conn.req_cookies,
        url: "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}",
        user_ip: (conn.remote_ip |> Tuple.to_list() |> Enum.join(".")),
        headers: Enum.into(conn.req_headers, %{}),
        session: conn.private[:plug_session] || %{},
        params: conn.params,
        method: conn.method
      }, custom_data[:request] || %{}),

      server: Map.merge(%{
        host: node
      }, custom_data[:server] || %{}),

      custom: Map.merge(%{
        assigns: conn.assigns
      }, custom_data[:custom] || %{})
    })

    Rollbax.report(kind, reason, stacktrace, %{}, conn_data)
  end

  @doc """
  Tracks an eBay response, and reports it if it's problematic.
  """
  def track_ebay_response(
    conn, status,
    %{"exceptions" => %{"exception" => [%{"message" => message}]}} = body,
    headers)
  do
    report(conn, %{
      kind: :throw,
      reason: :"[eBay] #{message}",
      stack: System.stacktrace()
    }, %{
      fingerprint: "eBay exception #{message}",
      custom: %{
        ebay_body: body,
        ebay_status: status,
        ebay_headers: Enum.into(headers, %{})
      }
    })
  end

  def track_ebay_response(conn, status, body, headers)
  when status < 200 or status > 399 do
    report(conn, %{
      kind: :throw,
      reason: :"[eBay] Status #{status}",
      stack: System.stacktrace()
    }, %{
      fingerprint: "eBay status #{status}",
      custom: %{
        ebay_body: body,
        ebay_status: status,
        ebay_headers: Enum.into(headers, %{})
      }
    })
  end

  def track_ebay_response(_conn, _status, _body, _headers), do: true

  @doc """
  Tracks HTTPoison errors
  """
  def track_httpoison_error(conn, %HTTPoison.Error{reason: reason} = err) do
    report(conn, %{
     kind: :throw,
     reason: :"[HTTP] #{reason}",
     stack: System.stacktrace()
   }, %{
     fingerprint: "httpoison #{reason}",
     custom: %{err: err}
   })
  end
end

defmodule Apientry.ErrorReporter do
  @moduledoc """
  Reports errors
  """

  def report(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    conn = conn
    |> Plug.Conn.fetch_cookies()
    |> Plug.Conn.fetch_query_params()
    |> Plug.Conn.fetch_session()

    # Based on https://hexdocs.pm/rollbax/using-rollbax-in-plug-based-applications.html
    conn_data = %{
      "request" => %{
        "cookies" => conn.req_cookies,
        "url" => "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}",
        "user_ip" => (conn.remote_ip |> Tuple.to_list() |> Enum.join(".")),
        "headers" => Enum.into(conn.req_headers, %{}),
        "session" => conn.private[:plug_session] || %{},
        "params" => conn.params,
        "method" => conn.method
      },
      "server" => %{
        "host" => node
      }
    }

    Rollbax.report(kind, reason, stack, %{}, conn_data)
  end
end

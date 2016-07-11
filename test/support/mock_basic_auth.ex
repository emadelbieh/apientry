defmodule Apientry.MockBasicAuth do
  @moduledoc """
  Tests authentication via basic auth.
  """

  import Plug.Conn, only: [put_req_header: 3]

  @username Application.get_env(:apientry, :basic_auth)[:username]
  @password Application.get_env(:apientry, :basic_auth)[:password]

  def auth(conn) do
    header_content = "Basic " <> Base.encode64("#{@username}:#{@password}")
    conn
    |> put_req_header("authorization", header_content)
  end

  defmacro __using__(_module, _opts \\ nil) do
    quote do
      setup %{conn: conn} do
        conn = conn
        |> Apientry.MockBasicAuth.auth()
        {:ok, conn: conn}
      end
    end
  end
end

defmodule Apientry.CatchAllController do
  use Apientry.Web, :controller
  def catch_all(conn, _) do
    json conn, %{message: "ok"}
  end
end

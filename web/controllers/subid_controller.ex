defmodule Apientry.SubIdController do
  use Apientry.Web, :controller

  def generate(conn, _) do
    subid = RandomBytes.base62(5)
    text(conn, subid)
  end
end

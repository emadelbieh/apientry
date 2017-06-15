defmodule Apientry.SessionController do
  use Apientry.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end
end

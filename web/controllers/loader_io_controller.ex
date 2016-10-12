defmodule Apientry.LoaderIoController do
  use Apientry.Web, :controller

  def index(conn, %{}) do
    text(conn, "loaderio-ed96d28cb6cb372defb0748d98689a27")
  end
end

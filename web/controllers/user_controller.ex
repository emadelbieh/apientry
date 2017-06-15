defmodule Apientry.UserController do
  use Apientry.Web, :controller

  def index(conn, _params) do
    case authenticate(conn) do
      %Plug.Conn{halted: true} = conn ->
        conn
      conn ->
        users = Repo.all(User)
        render conn, "index.html", users: users
    end
  end

  def authenticate(conn) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end

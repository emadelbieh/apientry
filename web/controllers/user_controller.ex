defmodule Apientry.UserController do
  use Apientry.Web, :controller

  plug :authenticate_user

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end
end

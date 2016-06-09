defmodule Apientry.SearchController do
  use Apientry.Web, :controller

  alias Apientry.Search

  # plug :scrub_params, "search" when action in [:create, :update]

  def search(conn, _params) do
    render(conn, "index.json", json: %{hello: "world"})
  end
end

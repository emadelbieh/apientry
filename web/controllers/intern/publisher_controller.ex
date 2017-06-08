defmodule Apientry.Intern.PublisherController do
  use Apientry.Web, :controller

  alias Apientry.Publisher

  def index(conn, _params) do
    publishers = Repo.all(Publisher)
                 |> Repo.preload(api_keys: [:tracking_ids])
                 |> Repo.preload(:publisher_sub_ids)
    render(conn, "index.json", publishers: publishers)
  end

  def show(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)
                |> Repo.preload(api_keys: [:tracking_ids])
                |> Repo.preload(:publisher_sub_ids)
    render(conn, "show.json", publisher: publisher)
  end
end

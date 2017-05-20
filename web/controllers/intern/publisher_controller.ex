defmodule Apientry.Intern.PublisherController do
  use Apientry.Web, :controller

  alias Apientry.Publisher

  def index(conn, _params) do
    publishers = Repo.all(Publisher) |> Repo.preload(publisher_api_keys: [:tracking_ids])
    render(conn, "index.json", publishers: publishers)
  end

  def create(conn, %{"publisher" => publisher_params}) do
    changeset = Publisher.changeset(%Publisher{}, publisher_params)

    case Repo.insert(changeset) do
      {:ok, publisher} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", publisher_path(conn, :show, publisher))
        |> render("show.json", publisher: publisher)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Apientry.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)
    render(conn, "show.json", publisher: publisher)
  end

  def update(conn, %{"id" => id, "publisher" => publisher_params}) do
    publisher = Repo.get!(Publisher, id)
    changeset = Publisher.changeset(publisher, publisher_params)

    case Repo.update(changeset) do
      {:ok, publisher} ->
        render(conn, "show.json", publisher: publisher)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Apientry.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(publisher)

    send_resp(conn, :no_content, "")
  end
end

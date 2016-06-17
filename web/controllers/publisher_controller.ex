defmodule Apientry.PublisherController do
  use Apientry.Web, :controller

  alias Apientry.{
    Publisher,
    Feed,
    PublisherFeed
  }

  plug :scrub_params, "publisher" when action in [:create, :update]

  def index(conn, _params) do
    publishers =
      from(p in Publisher, order_by: p.inserted_at)
      |> Repo.all

    render(conn, "index.html", publishers: publishers)
  end

  def new(conn, _params) do
    changeset = Publisher.changeset(%Publisher{})
    render(conn, "new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)
    render(conn, "show.html", publisher: publisher)
  end

  def create(conn, %{"publisher" => publisher_params}) do
    changeset = Publisher.changeset(%Publisher{}, publisher_params)

    case Repo.insert(changeset) do
      {:ok, _publisher} ->
        conn
        |> put_flash(:info, "Publisher created successfully.")
        |> redirect(to: publisher_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)
    changeset = Publisher.changeset(publisher)

    render(conn, "edit.html", publisher: publisher, changeset: changeset)
  end

  def update(conn, %{"id" => id, "publisher" => publisher_params}) do
    publisher = Repo.get!(Publisher, id)
    changeset = Publisher.changeset(publisher, publisher_params)

    case Repo.update(changeset) do
      {:ok, _publisher} ->
        conn
        |> put_flash(:info, "Publisher updated successfully.")
        |> redirect(to: publisher_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", publisher: publisher, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)

    Repo.delete!(publisher)

    conn
    |> put_flash(:info, "Publisher deleted successfully.")
    |> redirect(to: publisher_path(conn, :index))
  end

  def regenerate(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)
    changeset = Publisher.api_key_changeset(publisher)

    case Repo.update(changeset) do
      {:ok, publisher} ->
        conn
        |> put_flash(:info, "New API Key generated for #{publisher.name}")
        |> redirect(to: publisher_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to generate API Key for #{publisher.name}")
        |> redirect(to: publisher_path(conn, :index))
    end
  end
end

defmodule Apientry.PublisherController do
  use Apientry.Web, :controller

  alias Apientry.{Publisher}

  plug :scrub_params, "publisher" when action in [:create, :update]

  def index(conn, _params) do
    publishers =
      from(p in Publisher,
        order_by: p.inserted_at,
        preload: :api_keys)
      |> Repo.all

    render(conn, "index.html", publishers: publishers)
  end

  def new(conn, _params) do
    changeset = Publisher.changeset(%Publisher{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"publisher" => publisher_params}) do
    changeset = Publisher.changeset(%Publisher{}, publisher_params)

    case Repo.insert(changeset) do
      {:ok, _publisher} ->
        DbCache.update(:publisher)
        conn
        |> put_flash(:info, "Publisher created successfully.")
        |> redirect(to: publisher_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id) |> Repo.preload(:api_keys)
    tracking_ids = assoc(publisher.api_keys, :tracking_ids) |> Repo.all
    render(conn, "show.html", publisher: publisher, tracking_ids: tracking_ids, api_keys: publisher.api_keys)
  end

  def edit(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)
    changeset = Publisher.changeset(publisher)

    render(conn, "edit.html", publisher: publisher, changeset: changeset)
  end

  def update(conn, %{"id" => id, "publisher" => publisher_params}) do
    publisher = Repo.get!(Publisher, id) |> Repo.preload(:tracking_ids)
    changeset = Publisher.changeset(publisher, publisher_params)

    case Repo.update(changeset) do
      {:ok, _publisher} ->
        DbCache.update(:publisher)
        conn
        |> put_flash(:info, "Publisher updated successfully.")
        conn
        |> redirect(to: publisher_path(conn, :show, publisher))
      {:error, changeset} ->
        render(conn, "edit.html", publisher: publisher, changeset: changeset, tracking_ids: publisher.tracking_ids)
    end
  end

  def delete(conn, %{"id" => id}) do
    publisher = Repo.get!(Publisher, id)

    Repo.delete!(publisher)
    DbCache.update(:publisher)

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
        |> redirect(to: publisher_path(conn, :show, publisher))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to generate API Key for #{publisher.name}")
        |> redirect(to: publisher_path(conn, :show, publisher))
    end
  end
end

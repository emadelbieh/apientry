defmodule Apientry.PublisherApiKeyController do
  use Apientry.Web, :controller

  alias Apientry.Publisher
  alias Apientry.PublisherApiKey

  def index(conn, %{"publisher_id" => publisher_id}) do
    publisher = Repo.get(Publisher, publisher_id)
    publisher_api_keys = Repo.all(PublisherApiKey)
    render(conn, "index.html", publisher_api_keys: publisher_api_keys, publisher: publisher)
  end

  def new(conn, _params) do
    changeset = PublisherApiKey.changeset(%PublisherApiKey{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"publisher_api_key" => publisher_api_key_params}) do
    changeset = PublisherApiKey.changeset(%PublisherApiKey{}, publisher_api_key_params)

    case Repo.insert(changeset) do
      {:ok, _publisher_api_key} ->
        conn
        |> put_flash(:info, "Publisher api key created successfully.")
        |> redirect(to: publisher_api_key_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)
    render(conn, "show.html", publisher_api_key: publisher_api_key)
  end

  def edit(conn, %{"id" => id}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)
    changeset = PublisherApiKey.changeset(publisher_api_key)
    render(conn, "edit.html", publisher_api_key: publisher_api_key, changeset: changeset)
  end

  def update(conn, %{"id" => id, "publisher_api_key" => publisher_api_key_params}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)
    changeset = PublisherApiKey.changeset(publisher_api_key, publisher_api_key_params)

    case Repo.update(changeset) do
      {:ok, publisher_api_key} ->
        conn
        |> put_flash(:info, "Publisher api key updated successfully.")
        |> redirect(to: publisher_api_key_path(conn, :show, publisher_api_key))
      {:error, changeset} ->
        render(conn, "edit.html", publisher_api_key: publisher_api_key, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(publisher_api_key)

    conn
    |> put_flash(:info, "Publisher api key deleted successfully.")
    |> redirect(to: publisher_api_key_path(conn, :index))
  end
end

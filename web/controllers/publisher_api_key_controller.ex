defmodule Apientry.PublisherApiKeyController do
  use Apientry.Web, :controller

  alias Apientry.Publisher
  alias Apientry.PublisherApiKey

  plug :scrub_params, "publisher_api_key" when action in [:create, :update]

  def index(conn, %{"publisher_id" => publisher_id}) do
    publisher = Repo.get(Publisher, publisher_id)
    publisher_api_keys = Repo.all(assoc(publisher, :api_keys))
    render(conn, "index.html", publisher_api_keys: publisher_api_keys, publisher: publisher)
  end

  def new(conn, %{"publisher_id" => publisher_id}) do
    changeset = PublisherApiKey.changeset(%PublisherApiKey{}, %{publisher_id: publisher_id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"publisher_api_key" => publisher_api_key_params}) do
    publisher_api_key_params = if publisher_api_key_params["value"] == nil do
      Map.put(publisher_api_key_params, "value", Ecto.UUID.generate)
    else
      publisher_api_key_params
    end

    changeset = PublisherApiKey.changeset(%PublisherApiKey{}, publisher_api_key_params)

    case Repo.insert(changeset) do
      {:ok, _publisher_api_key} ->
        DbCache.update(:publisher_api_key)
        conn
        |> put_flash(:info, "Publisher api key created successfully.")
        |> redirect(to: publisher_api_key_path(conn, :index, publisher_id: publisher_api_key_params["publisher_id"]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)
    publishers = Publisher |> PublisherApiKey.names_and_ids |> Repo.all
    changeset = PublisherApiKey.changeset(publisher_api_key)
    render(conn, "edit.html", publisher_api_key: publisher_api_key, publishers: publishers, changeset: changeset)
  end

  def update(conn, %{"publisher_id" => _publisher_id, "id" => id, "publisher_api_key" => publisher_api_key_params}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)
    changeset = PublisherApiKey.changeset(publisher_api_key, publisher_api_key_params)

    case Repo.update(changeset) do
      {:ok, _publisher_api_key} ->
        DbCache.update(:publisher_api_key)
        conn
        |> put_flash(:info, "Publisher api key updated successfully.")
        |> redirect(to: publisher_api_key_path(conn, :index))
      {:error, changeset} ->
        publishers = Publisher |> PublisherApiKey.names_and_ids |> Repo.all
        render(conn, "edit.html", publisher_api_key: publisher_api_key, changeset: changeset, publishers: publishers)
    end
  end

  def update(conn, %{"id" => id, "publisher_api_key" => publisher_api_key_params}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)
    changeset = PublisherApiKey.changeset(publisher_api_key, publisher_api_key_params)

    case Repo.update(changeset) do
      {:ok, _publisher_api_key} ->
        DbCache.update(:publisher_api_key)
        conn
        |> put_flash(:info, "Publisher api key updated successfully.")
        |> redirect(to: publisher_api_key_path(conn, :index))
      {:error, changeset} ->
        publishers = Publisher |> PublisherApiKey.names_and_ids |> Repo.all
        render(conn, "edit.html", publisher_api_key: publisher_api_key, changeset: changeset, publishers: publishers)
    end
  end

  def delete(conn, %{"id" => id}) do
    publisher_api_key = Repo.get!(PublisherApiKey, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(publisher_api_key)
    DbCache.update(:publisher_api_key)

    conn
    |> put_flash(:info, "Publisher api key deleted successfully.")
    |> redirect(to: publisher_api_key_path(conn, :index, publisher_id: publisher_api_key.publisher_id))
  end
end

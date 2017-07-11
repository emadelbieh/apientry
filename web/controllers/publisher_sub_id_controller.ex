defmodule Apientry.PublisherSubIdController do
  use Apientry.Web, :controller

  alias Apientry.PublisherSubId

  def index(conn, _params) do
    publisher_sub_ids = Repo.all(PublisherSubId) |> Repo.preload(:publisher)
    render(conn, "index.html", publisher_sub_ids: publisher_sub_ids)
  end

  def new(conn, _params) do
    changeset = PublisherSubId.changeset(%PublisherSubId{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"publisher_sub_id" => publisher_sub_id_params}) do
    changeset = PublisherSubId.changeset(%PublisherSubId{}, publisher_sub_id_params)

    case Repo.insert(changeset) do
      {:ok, _publisher_sub_id} ->
        DbCache.update(:publisher_sub_id)
        conn
        |> put_flash(:info, "Publisher sub created successfully.")
        |> redirect(to: publisher_sub_id_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publisher_sub_id = Repo.get!(PublisherSubId, id)
    render(conn, "show.html", publisher_sub_id: publisher_sub_id)
  end

  def edit(conn, %{"id" => id}) do
    publisher_sub_id = Repo.get!(PublisherSubId, id)
    changeset = PublisherSubId.changeset(publisher_sub_id)
    render(conn, "edit.html", publisher_sub_id: publisher_sub_id, changeset: changeset)
  end

  def update(conn, %{"id" => id, "publisher_sub_id" => publisher_sub_id_params}) do
    publisher_sub_id = Repo.get!(PublisherSubId, id)
    changeset = PublisherSubId.changeset(publisher_sub_id, publisher_sub_id_params)

    case Repo.update(changeset) do
      {:ok, publisher_sub_id} ->
        DbCache.update(:publisher_sub_id)
        conn
        |> put_flash(:info, "Publisher sub updated successfully.")
        |> redirect(to: publisher_sub_id_path(conn, :show, publisher_sub_id))
      {:error, changeset} ->
        render(conn, "edit.html", publisher_sub_id: publisher_sub_id, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    publisher_sub_id = Repo.get!(PublisherSubId, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(publisher_sub_id)
    DbCache.update(:publisher_sub_id)

    conn
    |> put_flash(:info, "Publisher sub deleted successfully.")
    |> redirect(to: publisher_sub_id_path(conn, :index))
  end

  def query(conn, _params) do
    subids = Repo.all(from p in PublisherSubId, where: p.visual_search == ^true)
    json(conn, %{subids: format_subids(subids)})
  end

  def format_subids(subids) do
    subids
    |> Enum.map(fn subid ->
      %{
        sub_id: subid.sub_id,
        reference_data: subid.reference_data
      }
    end)
  end
end

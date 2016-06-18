defmodule Apientry.TrackingIdController do
  use Apientry.Web, :controller

  alias Apientry.{
    TrackingId,
    Publisher
  }

  plug :scrub_params, "tracking_id" when action in [:create, :update]

  def new(conn, %{"publisher_id" => pub_id}) do
    changeset = TrackingId.changeset(%TrackingId{})
    publisher = Repo.get! Publisher, pub_id
    render(conn, "new.html", changeset: changeset, publisher: publisher)
  end

  def create(conn, %{"publisher_id" => pub_id, "tracking_id" => tracking_id_params}) do
    tracking_id_params = Map.put tracking_id_params, "publisher_id", pub_id
    changeset = TrackingId.changeset(%TrackingId{}, tracking_id_params)

    case Repo.insert(changeset) do
      {:ok, _tracking_id} ->
        conn
        |> put_flash(:info, "Tracking created successfully.")
        |> redirect(to: publisher_path(conn, :edit, pub_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, publisher: pub_id)
    end
  end

  def edit(conn, %{"publisher_id" => pub_id, "id" => id}) do
    tracking_id = Repo.get!(TrackingId, id)
    changeset = TrackingId.changeset(tracking_id)
    render(conn, "edit.html", tracking_id: tracking_id, changeset: changeset, publisher: pub_id)
  end

  def update(conn, %{"publisher_id" => pub_id, "id" => id, "tracking_id" => tracking_id_params}) do
    tracking_id = Repo.get!(TrackingId, id)
    changeset = TrackingId.changeset(tracking_id, tracking_id_params)

    case Repo.update(changeset) do
      {:ok, tracking_id} ->
        conn
        |> put_flash(:info, "Tracking updated successfully.")
        |> redirect(to: publisher_path(conn, :edit, pub_id))
      {:error, changeset} ->
        render(conn, "edit.html", tracking_id: tracking_id, changeset: changeset, publisher: pub_id)
    end
  end

  def delete(conn, %{"publisher_id" => pub_id, "id" => id}) do
    tracking_id = Repo.get!(TrackingId, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tracking_id)

    conn
    |> put_flash(:info, "Tracking deleted successfully.")
    |> redirect(to: publisher_path(conn, :edit, pub_id))
  end
end

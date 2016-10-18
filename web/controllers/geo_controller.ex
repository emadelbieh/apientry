defmodule Apientry.GeoController do
  use Apientry.Web, :controller

  alias Apientry.Geo

  def index(conn, _params) do
    geos = (from g in Geo, order_by: ^[asc: :inserted_at]) |> Repo.all
    render(conn, "index.html", geos: geos)
  end

  def new(conn, _params) do
    changeset = Geo.changeset(%Geo{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"geo" => geo_params}) do
    changeset = Geo.changeset(%Geo{}, geo_params)

    case Repo.insert(changeset) do
      {:ok, _geo} ->
        conn
        |> put_flash(:info, "Geo created successfully.")
        |> redirect(to: geo_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    geo = Repo.get!(Geo, id)
    changeset = Geo.changeset(geo)
    render(conn, "edit.html", geo: geo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "geo" => geo_params}) do
    geo = Repo.get!(Geo, id)
    changeset = Geo.changeset(geo, geo_params)

    case Repo.update(changeset) do
      {:ok, geo} ->
        conn
        |> put_flash(:info, "Geo updated successfully.")
        |> redirect(to: geo_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", geo: geo, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    geo = Repo.get!(Geo, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(geo)

    conn
    |> put_flash(:info, "Geo deleted successfully.")
    |> redirect(to: geo_path(conn, :index))
  end
end

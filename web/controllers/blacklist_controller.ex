defmodule Apientry.BlacklistController do
  use Apientry.Web, :controller

  alias Apientry.Blacklist

  def index(conn, _params) do
    blacklists = Repo.all(Blacklist)
    render(conn, "index.html", blacklists: blacklists)
  end

  def new(conn, _params) do
    changeset = Blacklist.changeset(%Blacklist{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"blacklist" => blacklist_params}) do
    changeset = Blacklist.changeset(%Blacklist{}, blacklist_params)

    case Repo.insert(changeset) do
      {:ok, _blacklist} ->
        conn
        |> put_flash(:info, "Blacklist created successfully.")
        |> redirect(to: blacklist_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    blacklist = Repo.get!(Blacklist, id)
    render(conn, "show.html", blacklist: blacklist)
  end

  def edit(conn, %{"id" => id}) do
    blacklist = Repo.get!(Blacklist, id)
    changeset = Blacklist.changeset(blacklist)
    render(conn, "edit.html", blacklist: blacklist, changeset: changeset)
  end

  def update(conn, %{"id" => id, "blacklist" => blacklist_params}) do
    blacklist = Repo.get!(Blacklist, id)
    changeset = Blacklist.changeset(blacklist, blacklist_params)

    case Repo.update(changeset) do
      {:ok, blacklist} ->
        conn
        |> put_flash(:info, "Blacklist updated successfully.")
        |> redirect(to: blacklist_path(conn, :show, blacklist))
      {:error, changeset} ->
        render(conn, "edit.html", blacklist: blacklist, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    blacklist = Repo.get!(Blacklist, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(blacklist)

    conn
    |> put_flash(:info, "Blacklist deleted successfully.")
    |> redirect(to: blacklist_path(conn, :index))
  end
end

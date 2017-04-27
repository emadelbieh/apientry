defmodule Apientry.BlacklistController do
  use Apientry.Web, :controller

  alias Apientry.Blacklist
  alias Apientry.PublisherSubId

  def index(conn, _params) do
    blacklists = Repo.all(Blacklist) |> Repo.preload(publisher_sub_id: [:publisher])
    render(conn, "index.html", blacklists: blacklists)
  end

  defp load_publisher_sub_ids do
    subids = Repo.all(PublisherSubId)
             |> Repo.preload(:publisher)
             |> Enum.map(fn publisher_sub_id -> {"#{publisher_sub_id.publisher.name} - #{publisher_sub_id.sub_id}", publisher_sub_id.id} end)
  end

  def new(conn, _params) do
    subids = load_publisher_sub_ids
    changeset = Blacklist.changeset(%Blacklist{})
    render(conn, "new.html", changeset: changeset, subids: subids)
  end

  def create(conn, %{"blacklist" => %{"all" => "false"}} = params) do
    blacklist_params = params["blacklist"]

    changeset = Blacklist.changeset(%Blacklist{}, blacklist_params)

    case Repo.insert(changeset) do
      {:ok, _blacklist} ->
        conn
        |> put_flash(:info, "Blacklist created successfully.")
        |> redirect(to: blacklist_path(conn, :index))
      {:error, changeset} ->
        subids = load_publisher_sub_ids
        render(conn, "new.html", changeset: changeset, subids: subids)
    end
  end

  def create(conn, %{"blacklist" => %{"all" => "true"}} = params) do
    blacklist_params = params["blacklist"]

    publisher_sub_id = Repo.get(PublisherSubId, blacklist_params["publisher_sub_id_id"])
    publisher_sub_ids = Repo.all(PublisherSubId, publisher_id: publisher_sub_id.publisher_id)

    Enum.each(publisher_sub_ids, fn psubid ->
      changeset = Blacklist.changeset(%Blacklist{}, Map.merge(blacklist_params, %{"publisher_sub_id_id" => psubid.id}))
      Repo.insert!(changeset)
    end)

    conn
    |> put_flash(:info, "All subids for the associated publisher has been blacklisted")
    |> redirect(to: blacklist_path(conn, :index))
  end

  def edit(conn, %{"id" => id}) do
    subids = load_publisher_sub_ids
    blacklist = Repo.get!(Blacklist, id)
    changeset = Blacklist.changeset(blacklist)
    render(conn, "edit.html", blacklist: blacklist, changeset: changeset, subids: subids)
  end

  def update(conn, %{"id" => id, "blacklist" => blacklist_params}) do
    blacklist = Repo.get!(Blacklist, id)
    changeset = Blacklist.changeset(blacklist, blacklist_params)

    case Repo.update(changeset) do
      {:ok, blacklist} ->
        conn
        |> put_flash(:info, "Blacklist updated successfully.")
        |> redirect(to: blacklist_path(conn, :index))
      {:error, changeset} ->
        subids = load_publisher_sub_ids
        render(conn, "edit.html", blacklist: blacklist, changeset: changeset, subids: subids)
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

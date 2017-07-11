defmodule Apientry.BlacklistController do
  use Apientry.Web, :controller

  alias Apientry.Blacklist
  alias Apientry.PublisherSubId

  plug :scrub_params, "filter" when action in [:search]

  plug :validate_platforms when action in [:query]
  plug :validate_input when action in [:create]

  def search(conn, %{"filter" => %{"subid" => nil, "type" => nil}} = params) do
    load_publisher_sub_ids
    index(conn, params)
  end

  def search(conn, %{"filter" => %{"subid" => subid, "type" => nil}}) do
    subids = load_publisher_sub_ids
    publisher_sub_id = Repo.get_by(PublisherSubId, %{sub_id: subid})
    blacklists = Repo.all(from b in Blacklist, where: b.publisher_sub_id_id == ^publisher_sub_id.id) |> Repo.preload(publisher_sub_id: [:publisher])
    render(conn, "index.html", blacklists: blacklists, subids: subids)
  end

  def search(conn, %{"filter" => %{"subid" => nil, "type" => blacklist_type}}) do
    subids = load_publisher_sub_ids
    blacklists = Repo.all(from b in Blacklist, where: b.blacklist_type == ^blacklist_type) |> Repo.preload(publisher_sub_id: [:publisher])
    render(conn, "index.html", blacklists: blacklists, subids: subids)
  end

  def search(conn, %{"filter" => %{"subid" => subid, "type" => blacklist_type}}) do
    subids = load_publisher_sub_ids
    publisher_sub_id = Repo.get_by(PublisherSubId, %{sub_id: subid})
    blacklists = Repo.all(from b in Blacklist, where: b.blacklist_type == ^blacklist_type and b.publisher_sub_id_id == ^publisher_sub_id.id) |> Repo.preload(publisher_sub_id: [:publisher])
    render(conn, "index.html", blacklists: blacklists, subids: subids)
  end

  def index(conn, _params) do
    subids = load_publisher_sub_ids
    blacklists = Repo.all(Blacklist) |> Repo.preload(publisher_sub_id: [:publisher])
    render(conn, "index.html", blacklists: blacklists, subids: subids)
  end

  defp load_publisher_sub_ids do
    Repo.all(PublisherSubId)
    |> Repo.preload(:publisher)
    |> Enum.map(fn publisher_sub_id -> publisher_sub_id.sub_id end)
  end

  defp load_publisher_sub_ids_with_ids do
    Repo.all(PublisherSubId)
    |> Repo.preload(:publisher)
    |> Enum.map(fn publisher_sub_id -> {"#{publisher_sub_id.publisher.name} - #{publisher_sub_id.sub_id}", publisher_sub_id.id} end)
  end

  def new(conn, _params) do
    subids = load_publisher_sub_ids_with_ids
    changeset = Blacklist.changeset(%Blacklist{})
    render(conn, "new.html", changeset: changeset, subids: subids)
  end

  def create(conn, %{"blacklist" => %{"all" => "false"}} = params) do
    blacklist_params = params["blacklist"]

    if blacklist_params["file"] do
      blacklist_params
      |> prepare_changesets()
      |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    else
      changeset = Blacklist.changeset(%Blacklist{}, blacklist_params)
      Repo.insert!(changeset)
    end

    DbCache.update(:blacklist)

    conn
    |> put_flash(:info, "Blacklist created successfully.")
    |> redirect(to: blacklist_path(conn, :index))
  end

  def create(conn, %{"blacklist" => %{"all" => "true"}} = params) do
    blacklist_params = params["blacklist"]

    publisher_sub_id = Repo.get(PublisherSubId, blacklist_params["publisher_sub_id_id"])
    publisher_sub_ids = Repo.all(from p in PublisherSubId, where: p.publisher_id == ^publisher_sub_id.publisher_id)

    Enum.each(publisher_sub_ids, fn psubid ->
      if blacklist_params["file"] do
        blacklist_params
        |> prepare_changesets(psubid)
        |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
      else
        changeset = Blacklist.changeset(%Blacklist{}, Map.merge(blacklist_params, %{"publisher_sub_id_id" => psubid.id}))
        Repo.insert!(changeset)
      end
    end)

    DbCache.update(:blacklist)

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
      {:ok, _blacklist} ->
        DbCache.update(:blacklist)
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
    DbCache.update(:blacklist)

    conn
    |> put_flash(:info, "Blacklist deleted successfully.")
    |> redirect(to: blacklist_path(conn, :index))
  end

  def query(conn, %{"platform" => platform, "domain" => domain, "subid" => subid}) do
    subid = Repo.get_by(PublisherSubId, sub_id: subid)
    blacklists = Repo.all(from b in Blacklist,
                          where: b.blacklist_type == ^platform
                          and b.value == ^domain
                          and b.publisher_sub_id_id == ^subid.id)
    case blacklists do
      [] ->
        json(conn, %{blacklist: false})
      [_ | _] ->
        json(conn, %{blacklist: true})
    end
  end

  defp validate_platforms(conn, _opts) do
    platform = conn.params["platform"]

    if platform && (platform in ["visual_search", "topbar"]) do
      conn
    else
      conn
      |> halt()
      |> json(%{error: "invalid platform"})
    end
  end

  def validate_input(conn, _opts) do
    blacklist_params = conn.params["blacklist"]

    blacklist_params = if blacklist_params["file"] do
      Map.merge(blacklist_params, %{ "value" =>
        "To make form valid. This will be discarded bec file is preferred."})
    else
      blacklist_params
    end

    changeset = Blacklist.changeset(%Blacklist{}, blacklist_params)

    case changeset.valid? do
      true ->
        conn
      false ->
        subids = load_publisher_sub_ids
        conn
        |> halt()
        |> put_flash(:error, "Please check your input")
        |> render("new.html", changeset: changeset, subids: subids)
    end
  end

  defp prepare_changesets(blacklist_params, subid) do
    blacklist_params
    |> get_domains()
    |> Stream.reject(&(&1 == ""))
    |> Enum.map(fn domain ->
      blacklist_params = Map.merge(blacklist_params, %{"value" => domain, "publisher_sub_id_id" => subid.id})
      Blacklist.changeset(%Blacklist{}, blacklist_params)
    end)
  end

  defp prepare_changesets(blacklist_params) do
    blacklist_params
    |> get_domains()
    |> Stream.reject(&(&1 == ""))
    |> Enum.map(fn domain ->
      blacklist_params = Map.merge(blacklist_params, %{"value" => domain})
      Blacklist.changeset(%Blacklist{}, blacklist_params)
    end)
  end

  defp get_domains(blacklist_params) do
    blacklist_params["file"].path
    |> File.read!()
    |> String.split("\n")
  end
end

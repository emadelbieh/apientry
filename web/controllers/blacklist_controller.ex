defmodule Apientry.BlacklistController do
  use Apientry.Web, :controller

  alias Apientry.Blacklist
  alias Apientry.PublisherSubId

  plug :validate_platforms when action in [:query]

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

    if blacklist_params["file"] do
      f = blacklist_params["file"].path
      domains = File.read!(f) |> String.split("\n")
      Enum.each(domains, fn domain ->
        case domain do
          "" ->
            nil
          value ->
            blacklist_params = Map.merge(blacklist_params, %{"value" => value})
            changeset = Blacklist.changeset(%Blacklist{}, blacklist_params)
            Repo.insert!(changeset)
        end
      end)
    else
      changeset = Blacklist.changeset(%Blacklist{}, blacklist_params)
      Repo.insert!(changeset)
    end

    conn
    |> put_flash(:info, "Blacklist created successfully.")
    |> redirect(to: blacklist_path(conn, :index))

        #case Repo.insert(changeset) do
      # #case {:ok, _blacklist} ->
        #caseconn
        #case|> put_flash(:info, "Blacklist created successfully.")
        #case|> redirect(to: blacklist_path(conn, :index))
      #{#case:error, changeset} ->
        #casesubids = load_publisher_sub_ids
        #caserender(conn, "new.html", changeset: changeset, subids: subids)
        #end
  end

  def create(conn, %{"blacklist" => %{"all" => "true"}} = params) do
    blacklist_params = params["blacklist"]

    publisher_sub_id = Repo.get(PublisherSubId, blacklist_params["publisher_sub_id_id"])
    publisher_sub_ids = Repo.all(PublisherSubId, publisher_id: publisher_sub_id.publisher_id)

    Enum.each(publisher_sub_ids, fn psubid ->
      if blacklist_params["file"] do
        f = blacklist_params["file"].path
        domains = File.read!(f) |> String.split("\n")
        Enum.each(domains, fn domain ->
          case domain do
            "" ->
              nil
            value ->
              blacklist_params = Map.merge(blacklist_params, %{"value" => value, "publisher_sub_id_id" => psubid.id})
              changeset = Blacklist.changeset(%Blacklist{}, blacklist_params)
              Repo.insert!(changeset)
          end
        end)
      else
        changeset = Blacklist.changeset(%Blacklist{}, Map.merge(blacklist_params, %{"publisher_sub_id_id" => psubid.id}))
        Repo.insert!(changeset)
      end
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

  def query(conn, %{"platform" => platform, "domain" => domain}) do
    blacklists = Repo.all(from b in Blacklist,
                          where: b.blacklist_type == ^platform
                          and b.value == ^domain)
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
end

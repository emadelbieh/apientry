defmodule Apientry.EbayApiKeyController do
  use Apientry.Web, :controller

  alias Apientry.Geo
  alias Apientry.Account
  alias Apientry.EbayApiKey
  alias Apientry.TrackingId
  alias Apientry.PublisherApiKey

  def index(conn, %{"account_id" => account_id}) do
    account = Repo.get(Account, account_id) |> Repo.preload(:geo)
    ebay_api_keys = assoc(account, :ebay_api_keys) |> Repo.all
    tracking_ids = if ebay_api_keys == [] do
      []
    else
      assoc(ebay_api_keys, :tracking_ids) |> Repo.all |> Repo.preload(:ebay_api_key)
    end
    render(conn, "index.html", ebay_api_keys: ebay_api_keys, account: account, geo: account.geo, tracking_ids: tracking_ids)
  end

  def new(conn, %{"account_id" => account_id}) do
    account = Repo.get(Account, account_id)
    changeset = EbayApiKey.changeset(%EbayApiKey{}, %{account_id: account_id})
    render(conn, "new.html", changeset: changeset, account: account)
  end

  def create(conn, %{"ebay_api_key" => ebay_api_key_params}) do
    account = Repo.get(Account, ebay_api_key_params["account_id"])
    changeset = EbayApiKey.changeset(%EbayApiKey{}, ebay_api_key_params)

    case Repo.insert(changeset) do
      {:ok, _ebay_api_key} ->
        DbCache.update(:ebay_api_key)
        conn
        |> put_flash(:info, "Ebay api key created successfully.")
        |> redirect(to: ebay_api_key_path(conn, :index, account_id: ebay_api_key_params["account_id"]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, account: account)
    end
  end

  def show(conn, %{"id" => id, "account_id" => account_id}) do
    account = Repo.get(Account, account_id)
    geo = Repo.get(Geo, account.geo_id)
    ebay_api_key = Repo.get!(EbayApiKey, id)
    publisher_api_key_ids = from(t in TrackingId, where: t.ebay_api_key_id==^ebay_api_key.id, distinct: true, select: t.publisher_api_key_id) |> Repo.all
    publisher_api_keys = from(p in PublisherApiKey, where: p.id in ^publisher_api_key_ids) |> Repo.all |> Repo.preload(:publisher)
    render(conn, "show.html", ebay_api_key: ebay_api_key, account: account, geo: geo, publisher_api_keys: publisher_api_keys)
  end

  def edit(conn, %{"id" => id}) do
    ebay_api_key = Repo.get!(EbayApiKey, id)
    changeset = EbayApiKey.changeset(ebay_api_key)
    render(conn, "edit.html", ebay_api_key: ebay_api_key, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ebay_api_key" => ebay_api_key_params}) do
    ebay_api_key = Repo.get!(EbayApiKey, id)
    changeset = EbayApiKey.changeset(ebay_api_key, ebay_api_key_params)

    case Repo.update(changeset) do
      {:ok, ebay_api_key} ->
        DbCache.update(:ebay_api_key)
        conn
        |> put_flash(:info, "Ebay api key updated successfully.")
        |> redirect(to: ebay_api_key_path(conn, :index, account_id: ebay_api_key.account_id))
      {:error, changeset} ->
        render(conn, "edit.html", ebay_api_key: ebay_api_key, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ebay_api_key = Repo.get!(EbayApiKey, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(ebay_api_key)
    DbCache.update(:ebay_api_key)

    conn
    |> put_flash(:info, "Ebay api key deleted successfully.")
    |> redirect(to: ebay_api_key_path(conn, :index))
  end
end

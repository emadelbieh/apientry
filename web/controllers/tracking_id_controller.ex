defmodule Apientry.TrackingIdController do
  use Apientry.Web, :controller

  alias Apientry.{
    Geo,
    Account,
    EbayApiKey,
    PublisherApiKey,
    TrackingId,
    Publisher
  }

  plug :scrub_params, "tracking_id" when action in [:create, :update]

  def assign(conn, %{"publisher_id" => publisher_id} = params) do
    publisher = Repo.get(Publisher, publisher_id)
    api_keys = get_api_keys(publisher)
    geos = get_geos
    changeset = TrackingId.changeset(%TrackingId{})
    tracking_ids = get_tracking_ids(get_in(params, ["tracking_id", "ebay_publisher_key_id"]))
    render(conn, "assign.html", changeset: changeset, publisher: publisher,
      api_keys: api_keys, geos: geos, tracking_ids: tracking_ids)
  end

  defp get_api_keys(publisher) do
    assoc(publisher, :api_keys)
    |> PublisherApiKey.values_and_ids
    |> PublisherApiKey.sorted
    |> Repo.all
  end

  def get_tracking_ids(ebay_api_key_id) do
    case ebay_api_key_id do
      nil -> nil
      key -> 
        ebay_api_key = Repo.get(EbayApiKey, key)
        query = assoc(ebay_api_key, :tracking_ids)
        (from t in query, where: t.publisher_api_key==^nil, select: {t.code, t.id})
        |> Repo.all
    end
  end

  defp get_geos do
    Repo.all(Geo) |> Repo.preload(:accounts)
  end

  def new(conn, %{"account_id" => account_id}) do
    account = Repo.get(Account, account_id)
    ebay_api_keys = assoc(account, :ebay_api_keys)
                    |> EbayApiKey.values_and_ids
                    |> EbayApiKey.sorted
                    |> Repo.all
    changeset = TrackingId.changeset(%TrackingId{})
    render(conn, "new.html", changeset: changeset, account: account, ebay_api_keys: ebay_api_keys)
  end

  def index(conn, %{"publisher_id" => pub_id}) do
    publisher    = Repo.get!(Publisher, pub_id)
    api_keys     = Repo.all(assoc(publisher, :api_keys))
    tracking_ids = Repo.all(assoc(api_keys, :tracking_ids))
    render(conn, "index.html", publisher: publisher, tracking_ids: tracking_ids)
  end

  def create(conn, %{"tracking_id" => tracking_id_params, "account_id" => account_id}) do
    changeset = TrackingId.changeset(%TrackingId{}, tracking_id_params)

    case Repo.insert(changeset) do
      {:ok, _tracking_id} ->
        DbCache.update(:tracking_id)
        conn
        |> put_flash(:info, "Tracking created successfully.")
        |> redirect(to: ebay_api_key_path(conn, :index, account_id: account_id))
      {:error, changeset} ->
        account = Repo.get(Account, account_id)
        ebay_api_keys = assoc(account, :ebay_api_keys)
                        |> EbayApiKey.values_and_ids
                        |> EbayApiKey.sorted
                        |> Repo.all
        render(conn, "new.html", changeset: changeset, account: account, ebay_api_keys: ebay_api_keys)
    end
  end

  def edit(conn, %{"publisher_id" => pub_id, "id" => id}) do
    tracking_id = Repo.get!(TrackingId, id)
    publisher = Repo.get!(Publisher, pub_id)
    changeset = TrackingId.changeset(tracking_id)
    render(conn, "edit.html", tracking_id: tracking_id, changeset: changeset, publisher: publisher)
  end

  def update(conn, %{"publisher_id" => pub_id, "id" => id, "tracking_id" => tracking_id_params}) do
    tracking_id = Repo.get!(TrackingId, id)
    changeset = TrackingId.changeset(tracking_id, tracking_id_params)
    publisher = Repo.get!(Publisher, pub_id)

    case Repo.update(changeset) do
      {:ok, _tracking_id} ->
        DbCache.update(:tracking_id)
        conn
        |> put_flash(:info, "Tracking updated successfully.")
        |> redirect(to: publisher_tracking_id_path(conn, :index, pub_id))
      {:error, changeset} ->
        render(conn, "edit.html", tracking_id: tracking_id, changeset: changeset, publisher: publisher)
    end
  end

  def delete(conn, %{"publisher_id" => pub_id, "id" => id}) do
    tracking_id = Repo.get!(TrackingId, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tracking_id)
    DbCache.update(:tracking_id)

    conn
    |> put_flash(:info, "Tracking deleted successfully.")
    |> redirect(to: publisher_tracking_id_path(conn, :index, pub_id))
  end
end

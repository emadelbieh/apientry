defmodule Apientry.TrackingIdController do
  use Apientry.Web, :controller

  alias Apientry.{
    Account,
    EbayApiKey,
    TrackingId,
    Publisher
  }

  plug :scrub_params, "tracking_id" when action in [:create, :update]

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

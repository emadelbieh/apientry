defmodule Apientry.AssignmentController do
  use Apientry.Web, :controller
  
  alias Apientry.{
    Geo,
    Repo,
    Account,
    EbayApiKey,
    TrackingId,
    Publisher,
    PublisherApiKey
  }

  def step1(conn, %{"publisher_id" => publisher_id}) do
    publisher = Repo.get(Publisher, publisher_id)
    api_keys = get_api_keys(publisher)
    changeset = TrackingId.changeset(%TrackingId{}, %{})

    render(conn, "step1.html", changeset: changeset, action: assignment_path(conn, :step2),
                               publisher: publisher, publisher_api_keys: api_keys, geos: get_geos)
  end

  def step2(conn, %{"tracking_id" => %{"account_id" => account_id,
                                       "publisher_api_key_id" => publisher_api_key_id}}) do
    account = Repo.get(Account, account_id) |> Repo.preload(:ebay_api_keys)
    ebay_api_key_ids = get_ebay_api_key_ids(account)
    geo = account.geo

    publisher_api_key = Repo.get(PublisherApiKey, publisher_api_key_id) |> Repo.preload(:publisher)
    publisher = publisher_api_key.publisher

    changeset = TrackingId.changeset(%TrackingId{}, %{})

    render(conn, "step2.html", geo: geo, account: account, publisher: publisher, publisher_api_key: publisher_api_key, changeset: changeset, action: assignment_path(conn, :step3), ebay_api_key_ids: ebay_api_key_ids)
  end

  def step3(conn, %{"tracking_id" => %{"ebay_api_key_id" => ebay_api_key_id,
                                       "publisher_api_key_id" => publisher_api_key_id}}) do

    ebay_api_key = Repo.get(EbayApiKey, ebay_api_key_id) |> Repo.preload(:account)
    account = ebay_api_key.account
    tracking_ids = get_tracking_ids(ebay_api_key)

    publisher_api_key = Repo.get(PublisherApiKey, publisher_api_key_id) |> Repo.preload(:publisher)
    publisher = publisher_api_key.publisher

    changeset = TrackingId.changeset(%TrackingId{}, %{})

    render(conn, "step3.html", changeset: changeset, action: assignment_path(conn, :assign), ebay_api_key: ebay_api_key, tracking_ids: tracking_ids, publisher: publisher, account: account, publisher_api_key: publisher_api_key)
  end

  def assign(conn, %{"tracking_id" => %{"tracking_id_id" => id, "publisher_api_key_id" => publisher_api_key_id}}) do
    tracking_id = Repo.get!(TrackingId, id)
    changeset = TrackingId.changeset(tracking_id, %{publisher_api_key_id: publisher_api_key_id})

    Repo.update!(changeset)
    DbCache.update(:tracking_id)

    publisher_api_key = Repo.get!(PublisherApiKey, publisher_api_key_id) |> Repo.preload(:publisher)

    conn
    |> put_flash(:info, "Tracking ID successfully assigned")
    |> redirect(to: publisher_tracking_id_path(conn, :index, publisher_api_key.publisher))
  end

  def unassign(conn, %{"id" => id, "publisher_id" => pub_id}) do
    tracking_id = Repo.get!(TrackingId, id)
    changeset = TrackingId.changeset(tracking_id, %{publisher_api_key_id: nil})
    Repo.update!(changeset)
    DbCache.update(:tracking_id)

    conn
    |> put_flash(:info, "Tracking ID has been successfully unassigned")
    |> redirect(to: publisher_tracking_id_path(conn, :index, pub_id))
  end

  defp get_geos do
    Repo.all(Geo) |> Repo.preload(:accounts)
  end

  defp get_api_keys(publisher) do
    assoc(publisher, :api_keys)
    |> PublisherApiKey.values_and_ids
    |> PublisherApiKey.sorted
    |> Repo.all
  end

  def get_ebay_api_key_ids(account) do
    assoc(account, :ebay_api_keys)
    |> EbayApiKey.values_and_ids
    |> Repo.all
  end

  defp get_tracking_ids(ebay_api_key) do
      query = assoc(ebay_api_key, :tracking_ids)
      (from t in query, where: is_nil(t.publisher_api_key_id), select: {t.code, t.id})
      |> Repo.all
  end
end

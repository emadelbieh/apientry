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
                                       "publisher_api_key_id" => publisher_api_key_id}} = params) do

    account = Repo.get(Account, account_id) |> Repo.preload(:ebay_api_keys)
    ebay_api_key_ids = get_ebay_api_key_ids(account)
    geo = account.geo

    publisher_api_key = Repo.get(PublisherApiKey, publisher_api_key_id) |> Repo.preload(:publisher)
    publisher = publisher_api_key.publisher

    changeset = TrackingId.changeset(%TrackingId{}, %{})

    render(conn, "step2.html", geo: geo, account: account, publisher: publisher, publisher_api_key: publisher_api_key, changeset: changeset, action: assignment_path(conn, :step3), ebay_api_key_ids: ebay_api_key_ids)
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
    query = assoc(account, :ebay_api_keys)
    (from e in query, select: {e.value, e.id})
    |> Repo.all
  end

  defp get_tracking_ids(ebay_api_key) do
      query = assoc(ebay_api_key, :tracking_ids)
      (from t in query, where: is_nil(t.publisher_api_key_id), select: {t.code, t.id})
      |> Repo.all
  end
end

defmodule Apientry.EbayApiKeyController do
  use Apientry.Web, :controller

  alias Apientry.Account
  alias Apientry.EbayApiKey

  def index(conn, %{"account_id" => account_id}) do
    account = Repo.get(Account, account_id)
    ebay_api_keys = Repo.all(from e in EbayApiKey, where: e.account_id == ^account_id)
    render(conn, "index.html", ebay_api_keys: ebay_api_keys, account: account)
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
        conn
        |> put_flash(:info, "Ebay api key created successfully.")
        |> redirect(to: ebay_api_key_path(conn, :index, account_id: ebay_api_key_params["account_id"]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    ebay_api_key = Repo.get!(EbayApiKey, id)
    render(conn, "show.html", ebay_api_key: ebay_api_key)
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
        conn
        |> put_flash(:info, "Ebay api key updated successfully.")
        |> redirect(to: ebay_api_key_path(conn, :show, ebay_api_key))
      {:error, changeset} ->
        render(conn, "edit.html", ebay_api_key: ebay_api_key, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ebay_api_key = Repo.get!(EbayApiKey, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(ebay_api_key)

    conn
    |> put_flash(:info, "Ebay api key deleted successfully.")
    |> redirect(to: ebay_api_key_path(conn, :index))
  end
end

defmodule Apientry.MerchantController do
  use Apientry.Web, :controller

  alias Apientry.Merchant

  def index(conn, _params) do
    merchants = Repo.all(Merchant)
    render(conn, "index.json", merchants: merchants)
  end

  def create(conn, %{"merchant" => merchant_params}) do
    changeset = Merchant.changeset(%Merchant{}, merchant_params)

    case Repo.insert(changeset) do
      {:ok, merchant} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", merchant_path(conn, :show, merchant))
        |> render("show.json", merchant: merchant)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Apientry.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    merchant = Repo.get!(Merchant, id)
    render(conn, "show.json", merchant: merchant)
  end

  def update(conn, %{"id" => id, "merchant" => merchant_params}) do
    merchant = Repo.get!(Merchant, id)
    changeset = Merchant.changeset(merchant, merchant_params)

    case Repo.update(changeset) do
      {:ok, merchant} ->
        render(conn, "show.json", merchant: merchant)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Apientry.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    merchant = Repo.get!(Merchant, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(merchant)

    send_resp(conn, :no_content, "")
  end
end

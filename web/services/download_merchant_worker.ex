defmodule Apientry.DownloadMerchantWorker do
  @endpoint "https://api.feeds4.com/merchants/?token=bl213euxg-scof-zq44-f3b4589h74&recordset=all&format=json"

  alias HTTPoison.Response
  alias Apientry.Merchant
  alias Apientry.Repo

  def perform do
    case HTTPoison.get(@endpoint) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        body = Poison.decode!(body)
        Enum.each(body["data"], fn merchant ->
          if(db_merchant = Repo.get(Merchant, merchant["id"])) do
            merchant = Map.delete(merchant, "id")
            changeset = Merchant.changeset(db_merchant, merchant)
            case Repo.update(changeset) do
              {:ok, merchant} ->
                IO.puts("Merchant #{merchant.id} successfully updated")
              {:error, changeset} ->
                IO.puts("Error saving merchant: #{changeset.id}")
            end
          else
            changeset = Merchant.changeset(%Merchant{}, merchant)
            case Repo.insert(changeset) do
              {:ok, merchant} ->
                IO.puts("Merchant #{merchant.id} successfully saved")
              {:error, changeset} ->
                IO.puts("Error saving merchant: #{changeset.id}")
            end
          end
        end)

      {:error, %HTTPoison.Error{reason: reason} = error} ->
        IO.puts "error"
    end
  end
end

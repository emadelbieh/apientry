defmodule Apientry.DownloadCouponWorker do
  @endpoint "https://api.feeds4.com/coupons/?token=bl213euxg-scof-zq44-f3b4589h74&recordset=test&format=json"

  alias HTTPoison.Response
  alias Apientry.Coupon
  alias Apientry.Repo
  alias Apientry.Reponse

  def perform do
    case HTTPoison.get(@endpoint) do
      {:ok,  %Response{status_code: status, body: body, headers: headers}} ->
        body = Poison.decode!(body)
        Enum.each(body["data"], fn coupon ->
          if(db_coupon = Repo.get(Coupon, coupon["id"])) do
            coupon = Map.delete(coupon, "id")
            changeset = Coupon.changeset(db_coupon, coupon)
            case Repo.update(changeset) do
              {:ok, coupon} ->
                IO.puts("Coupon #{coupon.id} successfully updated")
              {:error, changeset} ->
                IO.puts("Error saving coupon: #{changeset.id}")
            end
          else
            changeset = Coupon.changeset(%Coupon{}, coupon)
            case Repo.insert(changeset) do
              {:ok, coupon} ->
                IO.puts("Coupon #{coupon.id} successfully saved")
              {:error, changeset} ->
                IO.puts("Error saving coupon: #{changeset.id}")
            end
          end
        end)

      {:error, %HTTPoison.Error{reason: reason} = error} ->
        IO.puts "error"
    end
  end
end

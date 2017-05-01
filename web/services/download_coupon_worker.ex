defmodule Apientry.DownloadCouponWorker do
  @cache_path "hello"
  @endpoint "https://api.feeds4.com/coupons/?token=bl213euxg-scof-zq44-f3b4589h74&recordset=test&format=json"

  alias HTTPoison.Response
  alias Apientry.Coupon
  alias Apientry.Repo

  def perform do
    @endpoint
    |> query()
    |> save_to_file(@cache_path)

    @cache_path
    |> read_contents()
    |> parse_contents()
    |> cache_to_database()
  end

  defp query(endpoint) do
    case HTTPoison.get(@endpoint) do
      {:ok,  %Response{status_code: status, body: body, headers: headers} = response} ->
        body
      {:error, %HTTPoison.Error{reason: reason} = error} ->
        IO.inspect(error)
        nil
    end
  end

  defp save_to_file(data, cache_path) do
    case File.open(cache_path, [:write]) do
      {:ok, file} ->
        IO.binwrite file, data
        File.close(file)
        true
      _ ->
        false
    end
  end

  def read_contents(cache_path) do
    case File.read(cache_path) do
      {:ok, data} -> data
      _ -> %{}
    end
  end

  defp parse_contents(response) do
    Poison.decode!(response)["data"]
  end

  defp cache_to_database(coupons_data) do
    Repo.delete_all(Coupon)
    Enum.each(coupons_data, fn coupon_attrs ->
      create_record(coupon_attrs)
    end)
  end

  defp create_record(coupon_attrs) do
    changeset = Coupon.changeset(%Coupon{}, coupon_attrs)
    case Repo.insert(changeset) do
      {:ok, coupon} ->
        IO.puts("Coupon #{coupon.id} successfully saved")
      {:error, changeset} ->
        IO.puts("Error saving coupon:")
        IO.inspect changeset
    end
  end
end

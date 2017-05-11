defmodule Apientry.DownloadCouponWorker do
  @cache_path "coupons_cache"
  @endpoint "https://api.feeds4.com/coupons/?token=bl213euxg-scof-zq44-f3b4589h74&recordset=all&format=json"

  @min_coupons_desired 10_000
  @initial_delay_factor 1
  @max_delay_factor 512
  @one_second 1_000

  alias HTTPoison.Response
  alias Apientry.Coupon
  alias Apientry.Repo

  def perform do
    @cache_path
    |> analyze_attributes()
    |> query(@endpoint)
    |> save_to_file(@cache_path)

    @cache_path
    |> read_contents()
    |> parse_contents()
    |> cache_to_database()
  end

  def analyze_attributes(cache_file) do
    case File.stat(cache_file) do
      {:ok, stats} ->
        case should_refresh?(time_modified(stats), time_now()) do
          true -> {:miss, cache_file}
          false -> {:hit, cache_file}
        end
      {:error, :enoent} ->
        {:miss, cache_file}
    end
  end

  #
  # Queries the Feeds4 API coupons endpoint. If it contains 10,000 coupons or
  # more, we will return the raw data `body` for caching to file. If we got
  # less than 10k coupons, we'll query the api again for up to 10 times with
  # longer delay in between them. If we fail to get 10k coupons after 10 tries,
  # we return what we have for caching.
  #
  def query({:miss, cache_path}, endpoint, delay_factor \\ @initial_delay_factor) do
    case HTTPoison.get(endpoint) do
      {:ok,  %Response{status_code: status, body: body, headers: headers} = response} ->
        count = body
        |> parse_contents()
        |> Enum.count()

        cond do
          count >= @min_coupons_desired ->
            {:miss, body}
          delay_factor > @max_delay_factor ->
            {:miss, body}
          true ->
            :timer.sleep(@one_second * delay_factor)
            query({:miss, cache_path}, endpoint, delay_factor * 2)
        end
      {:error, %HTTPoison.Error{reason: reason} = error} ->
        {:error, error}
    end
  end

  def query({:hit, cache_path}, _endpoint, _delay_factor) do
    {:hit, cache_path}
  end

  def time_now do
    {_, {hour,_,_}} = Timex.to_erl(Timex.now)
    hour
  end

  def time_modified(%File.Stat{mtime: mtime}) do
    {_, {hour,_,_}} = mtime
    hour
  end

  def should_refresh?(hour_modified, hour_now) do
    cond do
      (hour_now in [6,12,18]) && (hour_modified < hour_now) ->
        true
      (hour_now == 0) && (hour_modified in 18..23) ->
        true
      true ->
        false
    end
  end

  def save_to_file({:miss, data}, cache_path) do
    case File.open(cache_path, [:write]) do
      {:ok, file} ->
        IO.binwrite file, data
        File.close(file)
        true
      _ ->
        false
    end
  end

  def save_to_file({:hit, _}, _) do
    # do nothing
  end

  def save_to_file({:error, error}) do
    IO.inspect error
  end

  def read_contents(cache_path) do
    case File.read(cache_path) do
      {:ok, data} -> data
      _ -> %{}
    end
  end

  def parse_contents(response) do
    Poison.decode!(response)["data"]
  end

  def cache_to_database(coupons_data) do
    Repo.delete_all(Coupon)
    coupons_data
    |> Stream.filter(&(&1["country"] == "US"))
    |> Enum.each(&(create_record(&1)))
  end

  def create_record(coupon_attrs) do
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

defmodule Apientry.DownloadMerchantWorker do
  @cache_path "merchants_cache"
  @endpoint "https://api.feeds4.com/merchants/?token=bl213euxg-scof-zq44-f3b4589h74&recordset=all&format=json"

  alias HTTPoison.Response
  alias Apientry.Merchant
  alias Apientry.Repo

  def perform do
    result = @cache_path
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

  def query({:miss, cache_path}, endpoint) do
    case HTTPoison.get(@endpoint) do
      {:ok,  %Response{status_code: status, body: body, headers: headers} = response} ->
        {:miss, body}
      {:error, %HTTPoison.Error{reason: reason} = error} ->
        IO.inspect(error)
        {:miss, Poison.encode(%{})}
    end
  end

  def query({:hit, cache_path}, _endpoint) do
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
    if (hour_now in [0,6,12,18]) && (hour_modified < hour_now)  do
      true
    else
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
    true
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

  def cache_to_database(merchants_data) do
    Repo.delete_all(Merchant)
    Enum.each(merchants_data, fn merchant_attrs ->
      create_record(merchant_attrs)
    end)
  end

  def create_record(merchant_attrs) do
    changeset = Merchant.changeset(%Merchant{}, merchant_attrs)
    case Repo.insert(changeset) do
      {:ok, merchant} ->
        IO.puts("Merchant #{merchant.id} successfully saved")
      {:error, changeset} ->
        IO.puts("Error saving merchant:")
        IO.inspect changeset
    end
  end
end

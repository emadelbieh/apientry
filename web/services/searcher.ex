defmodule Apientry.Searcher do
  @moduledoc """
  Validates from DB feeds, publishers, tracking IDs (et al) and returns info on
  what the HTTP request to be performed.

      pry> params = %{
      ...>   "apiKey" => "...",
      ...>   "keyword" => "nikon",
      ...>   "visitorIPAddress" => "203.168.4.23"
      ...>   "visitorUserAgent" => "Mozilla/5.0 (iPhone; U)"
      ...> }
      pry> Searcher.search("json", params)
      %{
        "valid" => true,
        "format" => "json",
        "is_mobile" => true,
        "country" => "US",
        "publisher_name" => "Buzzfeed",
        "url" => "http://api.ebaycommercenetwork.com/publ..."
      }

  `result["url"]` is the key here. The rest are only used for debugging purposes.

  If the request is invalid, it returns an object with `"valid" => false`:

      %{
        "valid" => false,
        "error" => :invalid_tracking_id,
        "details" => %{
          "tracking_id" => "3928"
        }
      }

  The possible errors are:

  - `:no_feed_associated` - there's no feed available for this `{country, mobile}` pair.
  - `:no_api_key` - no `"apiKey"` was given.
  - `:unknown_country` - the given IP isn't available in the GeoIP database.
  - `:invalid_api_key` - The given `"apiKey"` has no Publisher associated with it.
  - `:invalid_tracking_id` - The given `"trackingId"` doesn't belong to the publisher.
  - `:unknown_user_agent` - Can't figure out the user agent.
  - `:missing_parameters` - Some parameters are missing.
  """

  import Ecto.Query, only: [from: 2]

  alias Apientry.{Feed, Repo, MobileDetection, Publisher, TrackingId}
  # alias Apientry.EbaySearch
  # alias Apientry.IpLookup

  # Keep this sorted, please
  @required_params [
    "apiKey",
    "domain",
    "visitorIPAddress",
    "visitorUserAgent"
  ]

  @doc """
  Performs a search.

  See [Apientry.Searcher] for details and examples.
  """
  def search(format, params, conn \\ nil) do
    with \
      :ok              <- validate_params(params),
      {:ok, publisher} <- get_publisher(params),
      {:ok, country}   <- get_country(params),
      {:ok, is_mobile} <- get_is_mobile(params),
      :ok              <- validate_tracking_code(params, publisher),
      {:ok, feed}      <- get_feed(country, is_mobile)
    do
      params = put_in(params["apiKey"], feed.api_key)
      new_params = Map.delete(params, "domain")
      url = EbaySearch.search(format, new_params)
      %{
        valid: true,
        format: format,
        is_mobile: is_mobile,
        country: country,
        redirect_base: redirect_base_path(conn),
        publisher_name: publisher.name,
        params: params,
        url: url
      }
    else
      {:error, err, details} ->
        %{ valid: false, error: err, details: details }
      _ ->
        %{ valid: false, error: :unknown_error, details: %{} }
    end
  end

  def validate_params(params) do
    case @required_params -- Map.keys(params) do
      [] -> :ok
      missing -> {:error, :missing_parameters, %{required: missing}}
    end
  end

  @doc """
  Finds the country of the user.

  Returns the country as `{:ok, "US"}` or `{:error, message, details}`.
  """
  def get_country(%{"visitorIPAddress" => ip} = _params) do
    case IpLookup.lookup(ip) do
      nil -> {:error, :unknown_country, %{ip: ip}}
      country -> {:ok, country}
    end
  end

  @doc """
  Finds the publisher for the given API key.

  Returns the publisher as `{:ok, publisher}` or `{:error, message}`.
  """
  def get_publisher(%{"apiKey" => api_key} = _params) do
    case Repo.one(from p in Publisher, where: p.api_key == ^api_key) do
      nil -> {:error, :invalid_api_key, %{api_key: api_key}}
      publisher -> {:ok, publisher}
    end
  end

  def get_publisher(_) do
    {:error, :no_api_key, %{}}
  end

  @doc """
  Checks if a given request is mobile.

  Returns `{:ok, true | false}` or `{:error, message}`.

      pry> get_is_mobile(params)
      {:ok, false}
  """
  def get_is_mobile(%{"visitorUserAgent" => agent} = _params) do
    case MobileDetection.mobile?(agent) do
      nil -> {:error, :unknown_user_agent, %{agent: agent}}
      is_mobile -> {:ok, is_mobile}
    end
  end

  def get_is_mobile(_) do
    {:error, :unknown_user_agent, %{}}
  end

  @doc """
  Gets the feed for a given country/is_mobile.

  Returns `{:ok, feed}` or `{:error, message, details}`.

      pry> get_feed("US", true)
      {:ok, %Feed{...}}
  """
  def get_feed(country, is_mobile) do
    feed = from f in Feed,
      where: f.is_mobile == ^is_mobile and f.country_code == ^country,
      limit: 1

    case Repo.one(feed) do
      nil -> {:error, :no_feed_associated, %{is_mobile: is_mobile, country: country}}
      feed -> {:ok, feed}
    end
  end

  @doc """
  Validates that a given tracking ID belongs to a publisher.

  Returns either `:ok` or `{:error, message, details}`. When the given `params`
  doesr't have a `"trackingId"` key, it returns true.

      pry> validate_tracking_code(%{"trackingId" => "123"}, publisher)
      :ok
  """
  def validate_tracking_code(%{"trackingId" => t_id}, publisher) do
    tracking_id = from t in TrackingId,
      where: t.publisher_id == ^publisher.id and t.code == ^t_id,
      limit: 1

    case Repo.one(tracking_id) do
      nil -> {:error, :invalid_tracking_id, %{tracking_id: t_id}}
      _ -> :ok
    end
  end

  def validate_tracking_code(_, _) do
    :ok
  end

  defp redirect_base_path(nil = _conn) do
    "" # only ever happens in tests
  end

  defp redirect_base_path(conn) do
    Apientry.Router.Helpers.redirect_url(conn, :show, "")
  end
end

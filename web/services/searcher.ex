defmodule Apientry.Searcher do
  @moduledoc """
  Validates from DB feeds, publishers, tracking IDs (et al) and returns info on
  what the HTTP request to be performed.

      pry> params = %{
      ...>   {"apiKey", "..."},
      ...>   {"keyword", "nikon"},
      ...>   {"visitorIPAddress", "203.168.4.23"},
      ...>   {"visitorUserAgent", "Mozilla/5.0 (iPhone; U)"}
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

  `params` can either be a list of `{key, value}` string tuples or a map.

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

  alias Apientry.MobileDetection
  alias Apientry.StringKeyword
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

  See `Apientry.Searcher` for details and examples.
  """
  def search(format, endpoint, params, conn \\ nil) do
    # Convert List to Map for easy access.
    map_params = params |> Enum.into(%{})

    # Convert Keyword list into a list with string keys.
    raw_params = params |> Enum.into([])

    with \
      :ok              <- validate_params(map_params),
      {:ok, publisher_api_key} <- get_publisher_api_key(map_params),
      {:ok, publisher} <- get_publisher(publisher_api_key),
      {:ok, country}   <- get_country(map_params),
      {:ok, is_mobile} <- get_is_mobile(map_params),
      {:ok, tracking_id} <- validate_tracking_code(map_params, publisher_api_key),
      {:ok, ebay_api_key} <- get_feed(tracking_id)
      #{:ok, feed}      <- get_feed(country, is_mobile)
    do
      new_params = raw_params
      |> StringKeyword.put("apiKey", ebay_api_key.value)
      |> StringKeyword.delete("domain")

      url = EbaySearch.search(format, endpoint, new_params)
      %{
        valid: true,
        format: format,
        is_mobile: is_mobile,
        country: country,
        redirect_base: redirect_base_path(conn),
        publisher_api_key_value: publisher_api_key.value,
        publisher_name: publisher.name,
        params: map_params,
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
  Finds the publisher api key for the given API key.

  Returns the publisher api key as `{:ok, publisher_api_key}` or `{:error, message}`.
  """
  def get_publisher_api_key(%{"apiKey" => api_key} = _params) do
    case DbCache.lookup(:publisher_api_key, :value, api_key) do
      nil -> {:error, :invalid_api_key, %{api_key: api_key}}
      publisher_api_key -> {:ok, publisher_api_key}
    end
  end

  def get_publisher_api_key(_) do
    {:error, :no_api_key, %{}}
  end

  @doc """
  Finds the publisher for the given publisher id.

  Returns the publisher as `{:ok, publisher}` or `{:error, message}`.
  """
  def get_publisher(publisher_api_key) do
    case DbCache.lookup(:publisher, :id, publisher_api_key.publisher_id) do
      nil -> {:error, :invalid_publisher, %{api_key: publisher_api_key.value}}
      publisher -> {:ok, publisher}
    end
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
  def get_feed(tracking_id) do
    feed = DbCache.lookup(:ebay_api_key, :id, tracking_id.ebay_api_key_id)

    case feed do
      nil -> {:error, :no_feed_associated, %{}}
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
  def validate_tracking_code(%{"trackingId" => t_id}, publisher_api_key) do
    tracking_id = DbCache.lookup(:tracking_id, :publisher_code, {publisher_api_key.id, t_id})

    case tracking_id do
      nil -> {:error, :invalid_tracking_id, %{tracking_id: t_id}}
      _ -> {:ok, tracking_id}
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

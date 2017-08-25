defmodule Apientry.SubidLookupPlug do
  import Plug.Conn
  alias Apientry.Repo

  @errors %{
    not_found: "no tracking id associated with this subid / geo",
    not_recognized: "geo not recognized"
  }

  def init(opts) do
    opts
  end

  def call(%{params: params} = conn, _opts) do
    cond do
      unrecognized_geo?(conn) ->
        conn
        |> Phoenix.Controller.render(:error, data: %{error: @errors[:not_recognized]})
        |> halt

      valid_extension_search_params?(conn) ->
        ref_data = get_reference_data(conn)
                   |> String.split(";")
                   |> Enum.filter(fn ref -> ref =~ get_geo(conn) end)

        case ref_data do
          [] ->
            conn
            |> Phoenix.Controller.render(:error, data: %{error: @errors[:not_found]})
            |> halt
          [trio] ->
            [geo, publisher_api_key, tracking_id] = String.split(trio, ",")

            params =
              params
              |> Map.put("apiKey", publisher_api_key)
              |> Map.put("trackingId", tracking_id)

            Map.put(conn, :params, params)
        end

      true ->
        conn
    end
  end

  def get_geo(conn) do
    case get_req_header(conn, "cf-ipcountry") do
      [] ->
        "US" # we're on localhost (i.e. not on cloudflare, use US for testing)
      [geo] ->
        geo
    end
  end

  def unrecognized_geo?(conn) do
    !recognized_geo?(conn)
  end

  def recognized_geo?(conn) do
    get_geo(conn) in ~w(FR US AU DE GB)
  end

  def valid_extension_search_params?(%{params: params} = _conn) do
    params["subid"] && !params["apiKey"]
  end

  def get_reference_data(%{params: params} = _conn) do
    case Repo.get_by(Apientry.PublisherSubId, sub_id: params["subid"]) do
      nil ->
        ""
      publisher_sub_id ->
        publisher_sub_id.reference_data
    end
  end
end

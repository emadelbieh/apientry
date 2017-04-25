defmodule Apientry.CouponSearchController do
  use Apientry.Web, :controller

  alias Apientry.Coupon
  import Ecto.Query
  import Apientry.ParameterValidators, only: [reject_search_engines: 2]

  plug :assign_request_uri
  plug :assign_redirect_base
  plug :assign_ip_address
  plug :assign_country
  plug :reject_search_engines

  def search(conn, params) do
    track_coupon_search(conn, params)
    coupons = Coupon.by_params(conn)
    json conn, Coupon.to_map(coupons)
  end

  defp assign_ip_address(conn, _opts) do
    conn
    |> assign(:ip_address, get_ip_address(conn))
  end

  defp assign_request_uri(conn, _opts) do
    conn
    |> assign(:request_uri, "#{conn.scheme}://#{conn.host}:#{conn.port}/#{conn.request_path}?#{conn.query_string}")
  end

  defp assign_redirect_base(conn, _opts) do
    conn
    |> assign(:redirect_base, "#{conn.scheme}://#{conn.host}:#{conn.port}/redirect/")
  end

  defp assign_country(conn, _opts) do
    conn
    |> assign(:country, get_country(conn))
  end

  defp get_country(%{params: %{"country" => country}}), do: country

  defp get_country(conn) do
    ip = Enum.into(conn.req_headers, %{})["cf-connecting-ip"]

    case IpLookup.lookup(ip) do
      nil -> "US"
      "GB" -> "GB"
      country -> country
    end
  end

  def track_coupon_search(conn, params) do
    country = params["country"] || Apientry.CloudflareService.get_country(conn)
    data = Map.merge(params, %{
      "ip_address" => Apientry.CloudflareService.get_ip_address(conn),
      "geo" => country,
      "country" => country
    })
    Apientry.Analytics.track_query(conn, data)
  end

  def get_ip_address(conn) do
    case get_req_header(conn, "cf-connecting-ip") do
      [ip | _] -> ip
      [] ->
        {a,b,c,d} = conn.remote_ip
        "#{a}.#{b}.#{c}.#{d}"
    end
  end
end

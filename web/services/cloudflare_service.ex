defmodule Apientry.CloudflareService do
  def get_country(conn) do
    case get_req_header(conn, "cf-ipcountry") do
      [] -> nil
      geo -> geo
    end
  end

  def get_ip_address(conn) do
    case get_req_header(conn, "cf-connecting-ip") do
      [] -> nil
      ip -> ip
    end
  end

  def get_forwarded_for(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [] -> nil
      ff -> ff
    end
  end

  def get_forwarded_proto(conn) do
    get_req_header(conn, "x-forwarded-proto")
  end

  def get_cf_ray(conn) do
    get_req_header(conn, "cf-ray")
  end

  def get_cf_visitor(conn) do
    get_req_header(conn, "cf-visitor")
  end

  defp get_req_header(conn, key) do
    Plug.Conn.get_req_header(conn, key)
  end
end

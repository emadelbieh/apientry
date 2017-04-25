defmodule Apientry.PageController do
  use Apientry.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  @doc """
  For testing cloudflare values
  """
  def cloudflare_values(conn, _params) do
    map = %{
      country: get_req_header(conn, "cf-ipcountry"),
      ip: get_req_header(conn, "cf-connecting-ip"),
      fowarded_for: get_req_header(conn, "x-forwarded-for"),
      fowarded_proto: get_req_header(conn, "x-forwarded-proto"),
      cf_ray: get_req_header(conn, "cf-ray"),
      cf_visitor: get_req_header(conn, "cf-visitor")
    }

    json(conn, map)
  end
end

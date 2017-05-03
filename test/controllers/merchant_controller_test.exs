defmodule Apientry.MerchantControllerTest do
  use Apientry.ConnCase

  alias Apientry.Merchant
  @valid_attrs %{country: "some content", domain: "some content", logo: "some content", merchant: "some content", network: "some content", slug: "some content", url: "some content", website: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, merchant_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end
end

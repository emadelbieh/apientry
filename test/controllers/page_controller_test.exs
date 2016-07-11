defmodule Apientry.PageControllerTest do
  use Apientry.ConnCase
  use Apientry.MockBasicAuth

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<html"
  end
end

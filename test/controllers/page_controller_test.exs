defmodule Apientry.PageControllerTest do
  use Apientry.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "api entry"
  end
end

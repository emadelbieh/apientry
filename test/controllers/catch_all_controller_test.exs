defmodule Apientry.CatchAllControllerTest do
  use Apientry.ConnCase

  test "responds to unknown GET requests", %{conn: conn} do
    conn = get conn, "/rom-0"
    assert json_response(conn, 200) == %{"message" => "ok"}
  end

  test "responds to unknown POST requests", %{conn: conn} do
    conn = post conn, "/rom-0"
    assert json_response(conn, 200) == %{"message" => "ok"}
  end

  test "responds to unknown PUT requests", %{conn: conn} do
    conn = put conn, "/rom-0"
    assert json_response(conn, 200) == %{"message" => "ok"}
  end

  test "responds to unknown PATCH requests", %{conn: conn} do
    conn = patch conn, "/rom-0"
    assert json_response(conn, 200) == %{"message" => "ok"}
  end

  test "responds to unknown DELETE requests", %{conn: conn} do
    conn = delete conn, "/rom-0"
    assert json_response(conn, 200) == %{"message" => "ok"}
  end
end

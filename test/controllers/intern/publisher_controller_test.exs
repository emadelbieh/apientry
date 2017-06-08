defmodule Apientry.Intern.PublisherControllerTest do
  use Apientry.ConnCase

  alias Apientry.Publisher
  @valid_attrs %{name: "some content", revenue_share: "0.20"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, intern_publisher_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    publisher = Repo.insert!(%Publisher{}) |> Repo.preload(:publisher_sub_ids)
    conn = get conn, intern_publisher_path(conn, :show, publisher)
    assert json_response(conn, 200)["data"] == %{"id" => publisher.id,
      "name" => publisher.name,
      "revenue_share" => publisher.revenue_share,
      "report_receivers" => publisher.report_receivers,
      "subplacements" => [],
      "subids" => []}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, intern_publisher_path(conn, :show, -1)
    end
  end
end

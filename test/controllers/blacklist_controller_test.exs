defmodule Apientry.BlacklistControllerTest do
  use Apientry.ConnCase

  alias Apientry.Blacklist
  @valid_attrs %{blacklist_type: "some content", value: "some content"}
  @invalid_attrs %{}

  alias Apientry.{Publisher, PublisherSubId}

  setup do
    publisher = Repo.insert!(Publisher.changeset(%Publisher{}, %{name: "test", revenue_share: 0.10}))
    publisher_sub_id = Repo.insert!(PublisherSubId.changeset(%PublisherSubId{}, %{sub_id: "001", publisher_id: publisher.id}))
    publisher_sub_id2 = Repo.insert!(PublisherSubId.changeset(%PublisherSubId{}, %{sub_id: "002", publisher_id: publisher.id}))
    publisher_sub_id3 = Repo.insert!(PublisherSubId.changeset(%PublisherSubId{}, %{sub_id: "003", publisher_id: publisher.id}))
    {:ok, publisher_sub_id: publisher_sub_id, psubid2: publisher_sub_id2, psubid3: publisher_sub_id3}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, blacklist_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing blacklists"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, blacklist_path(conn, :new)
    assert html_response(conn, 200) =~ "New blacklist"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, publisher_sub_id: publisher_sub_id} do
    blacklist_params = Map.merge(@valid_attrs, %{publisher_sub_id_id: publisher_sub_id.id, all: "false"})
    conn = post conn, blacklist_path(conn, :create), blacklist: blacklist_params
    assert redirected_to(conn) == blacklist_path(conn, :index)
    assert Repo.get_by(Blacklist, @valid_attrs)
  end

  test "creates resource for all subids when 'all' is 'true'", %{conn: conn, publisher_sub_id: publisher_sub_id, psubid2: psubid2, psubid3: psubid3} do
    blacklist_params = Map.merge(@valid_attrs, %{publisher_sub_id_id: publisher_sub_id.id, all: "true"})
    conn = post conn, blacklist_path(conn, :create), blacklist: blacklist_params
    assert redirected_to(conn) == blacklist_path(conn, :index)

    blacklisted = Enum.map(Repo.all(Blacklist), &(&1.publisher_sub_id_id))
    assert publisher_sub_id.id in blacklisted
    assert psubid2.id in blacklisted
    assert psubid3.id in blacklisted
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, blacklist_path(conn, :create), blacklist: Map.merge(@invalid_attrs, %{all: "false"})
    assert html_response(conn, 200) =~ "New blacklist"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    blacklist = Repo.insert! %Blacklist{}
    conn = get conn, blacklist_path(conn, :edit, blacklist)
    assert html_response(conn, 200) =~ "Edit blacklist"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, publisher_sub_id: publisher_sub_id} do
    blacklist = Repo.insert! %Blacklist{}
    blacklist_params = Map.merge(@valid_attrs, %{publisher_sub_id_id: publisher_sub_id.id})
    conn = put conn, blacklist_path(conn, :update, blacklist), blacklist: blacklist_params
    assert redirected_to(conn) == blacklist_path(conn, :index)
    assert Repo.get_by(Blacklist, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    blacklist = Repo.insert! %Blacklist{}
    conn = put conn, blacklist_path(conn, :update, blacklist), blacklist: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit blacklist"
  end

  test "deletes chosen resource", %{conn: conn} do
    blacklist = Repo.insert! %Blacklist{}
    conn = delete conn, blacklist_path(conn, :delete, blacklist)
    assert redirected_to(conn) == blacklist_path(conn, :index)
    refute Repo.get(Blacklist, blacklist.id)
  end

  test "creates blacklist for each domain in the uploaded file",
      %{conn: conn, publisher_sub_id: publisher_sub_id} do
    file = %Plug.Upload{path: "test/fixtures/blacklist.txt", filename: "blacklist.txt"}

    blacklist_params = %{"publisher_sub_id_id" => publisher_sub_id.id,
                         "blacklist_type" => "visual_search",
                         "file" => file, "all" => "false"}

    conn = post conn, blacklist_path(conn, :create), blacklist: blacklist_params
    assert redirected_to(conn) == blacklist_path(conn, :index)

    blacklisted_subdomains = Repo.all(Blacklist) |> Enum.map(&(&1.value))
    assert "amazon.com" in blacklisted_subdomains
    assert "ebay.com" in blacklisted_subdomains
  end

  test "creates blacklist for each subid for each domain each domain in uploaded file",
      %{conn: conn, publisher_sub_id: publisher_sub_id, psubid2: psubid2, psubid3: psubid3} do

    file = %Plug.Upload{path: "test/fixtures/blacklist.txt", filename: "blacklist.txt"}

    blacklist_params = %{"publisher_sub_id_id" => psubid3.id,
                         "blacklist_type" => "visual_search",
                         "file" => file, "all" => "true"}

    conn = post conn, blacklist_path(conn, :create), blacklist: blacklist_params
    assert redirected_to(conn) == blacklist_path(conn, :index)

    blacklisted = Repo.all(Blacklist) |> Enum.map(&("#{&1.publisher_sub_id_id}-#{&1.value}"))
    assert "#{publisher_sub_id.id}-amazon.com" in blacklisted
    assert "#{psubid2.id}-amazon.com" in blacklisted
    assert "#{psubid3.id}-amazon.com" in blacklisted
    assert "#{publisher_sub_id.id}-ebay.com" in blacklisted
    assert "#{psubid2.id}-ebay.com" in blacklisted
    assert "#{psubid3.id}-ebay.com" in blacklisted
  end
end

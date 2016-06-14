defmodule Apientry.FeedTest do
  use Apientry.ModelCase

  alias Apientry.Feed

  @valid_attrs %{
    api_key: "some content",
    country_code: "some content",
    feed_type: "some content",
    is_active: true,
    is_mobile: true
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Feed.changeset(%Feed{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Feed.changeset(%Feed{}, @invalid_attrs)
    refute changeset.valid?
  end
end

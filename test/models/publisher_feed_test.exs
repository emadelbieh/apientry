defmodule Apientry.PublisherFeedTest do
  use Apientry.ModelCase

  alias Apientry.PublisherFeed

  @valid_attrs %{feed_id: 42, publisher_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PublisherFeed.changeset(%PublisherFeed{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PublisherFeed.changeset(%PublisherFeed{}, @invalid_attrs)
    refute changeset.valid?
  end
end

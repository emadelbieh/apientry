defmodule Apientry.LayoutView do
  use Apientry.Web, :view

  @doc """
  Returns the page title for a given `assigns` map.

      > page_title(@conn.assigns)
      "New user"
  """
  def page_title(%{view_module: view, view_template: template} = assigns) do
    page_title(view, template, assigns)
  end

  @doc """
  Returns the page title for a given `view`, `template` and `assigns`.

      iex> Apientry.LayoutView.page_title(Apientry.PublisherView, "index.html", %{})
      "Publishers"
  """
  def page_title(Apientry.PublisherView, "index.html", _),
    do: gettext "Publishers"

  def page_title(Apientry.PublisherView, "new.html", _),
    do: gettext "New publisher"

  def page_title(Apientry.PublisherView, "show.html", %{publisher: publisher}),
    do: gettext "%{publisher}", publisher: publisher.name

  def page_title(Apientry.PublisherView, "edit.html", %{publisher: publisher}),
    do: gettext "%{publisher} - Settings", publisher: publisher.name

  def page_title(Apientry.TrackingIdView, "index.html", %{publisher: publisher}),
    do: gettext "%{publisher} - Tracking IDs", publisher: publisher.name

  def page_title(Apientry.TrackingIdView, "edit.html", %{publisher: publisher}),
    do: gettext "%{publisher} - Edit tracking ID", publisher: publisher.name

  def page_title(Apientry.TrackingIdView, "new.html", %{publisher: publisher}),
    do: gettext "%{publisher} - New tracking ID", publisher: publisher.name

  def page_title(Apientry.FeedView, "index.html", _),
    do: gettext "Feeds"

  def page_title(Apientry.FeedView, "new.html", _),
    do: gettext "New feed"

  def page_title(Apientry.FeedView, "show.html", %{feed: feed}),
    do: gettext "%{feed}", feed: feed.feed_type

  def page_title(Apientry.FeedView, "edit.html", %{feed: feed}),
    do: gettext "%{feed} - Settings", feed: feed.feed_type

  def page_title(_, _, _),
    do: gettext "Apientry"
end

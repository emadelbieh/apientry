defmodule Apientry.Intern.PublisherView do
  use Apientry.Web, :view

  def render("index.json", %{publishers: publishers}) do
    %{data: render_many(publishers, Apientry.Intern.PublisherView, "publisher.json")}
  end

  def render("show.json", %{publisher: publisher}) do
    %{data: render_one(publisher, Apientry.Intern.PublisherView, "publisher.json")}
  end

  def render("publisher.json", %{publisher: publisher}) do
    %{id: publisher.id,
      name: publisher.name,
      revenue_share: publisher.revenue_share,
      report_receivers: publisher.report_receivers}
  end
end

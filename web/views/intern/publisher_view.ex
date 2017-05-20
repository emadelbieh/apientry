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
      receivers: publisher.report_receivers,
      subplacements: subplacements_for(publisher)}
  end

  defp subplacements_for(publisher) do
    publisher.api_keys
    |> Enum.flat_map(fn api_key ->
      api_key.tracking_ids
      |> Enum.map(fn tracking_id ->
        %{
          subplacement: tracking_id.subplacement,
          tracking_id: tracking_id.code,
        }
      end)
    end)
  end
end

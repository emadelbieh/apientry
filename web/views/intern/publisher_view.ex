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
      report_receivers: publisher.report_receivers,
      subplacements: subplacements_for(publisher),
      subids: subids_for(publisher)}
  end

  defp subplacements_for(publisher) do
    publisher.api_keys
    |> Enum.flat_map(fn api_key ->
      api_key.tracking_ids
      |> Enum.map(fn tracking_id ->
        %{
          subplacement: tracking_id.subplacement,
          tracking_id: tracking_id.code,
          account_number: tracking_id.ebay_api_key.account.account_number
        }
      end)
    end)
  end

  def subids_for(publisher) do
    publisher.publisher_sub_ids
    |> Enum.map(fn struct ->
      %{
        sub_id: struct.sub_id,
        reference_data: struct.reference_data
      }
    end)
  end
end

defmodule Apientry.PublisherSubId.TrackingIdController do
  use Apientry.Web, :controller

  alias Apientry.PublisherSubId

  def index(conn, %{"publisher_sub_id_id" => sub_id} = params) do
    sub_id = Repo.get(PublisherSubId, sub_id)
      |> Repo.preload(tracking_ids: :geo)
      |> Repo.preload(tracking_ids: :publisher_api_key)
    tracking_ids = sub_id.tracking_ids
    render(conn, "index.html", sub_id: sub_id, tracking_ids: tracking_ids)
  end
end

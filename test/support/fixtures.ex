defmodule Apientry.Fixtures do
  alias Apientry.{Feed, Publisher, TrackingId, Repo}
  @panda_key "panda-abc"

  def mock_feeds do
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "us-d", is_active: true, is_mobile: false, country_code: "US"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "us-m", is_active: true, is_mobile: true,  country_code: "US"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "gb-d", is_active: true, is_mobile: false, country_code: "GB"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "gb-m", is_active: true, is_mobile: true,  country_code: "GB"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "au-d", is_active: true, is_mobile: false, country_code: "AU"})
    Repo.insert!(%Feed{feed_type: "ebay", api_key: "au-m", is_active: true, is_mobile: true,  country_code: "AU"})
  end

  def mock_publishers do
    p = Repo.insert!(%Publisher{name: "Panda", api_key: @panda_key})
    Repo.insert!(%TrackingId{code: "panda-a", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "panda-b", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "panda-c", publisher_id: p.id})

    p = Repo.insert!(%Publisher{name: "Avast", api_key: "avast-abc"})
    Repo.insert!(%TrackingId{code: "avast-a", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "avast-b", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "avast-c", publisher_id: p.id})

    p = Repo.insert!(%Publisher{name: "Symantec", api_key: "symantec-abc"})
    Repo.insert!(%TrackingId{code: "symantec-a", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "symantec-b", publisher_id: p.id})
    Repo.insert!(%TrackingId{code: "symantec-c", publisher_id: p.id})
  end
end

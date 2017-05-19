defmodule Apientry.Fixtures do
  alias Apientry.{Feed, Publisher, TrackingId, Repo}

  def mock_feeds do
    Repo.insert!(%Feed{feed_type: "ebay", is_active: true, is_mobile: false, country_code: "US"})
    Repo.insert!(%Feed{feed_type: "ebay", is_active: true, is_mobile: true,  country_code: "US"})
    Repo.insert!(%Feed{feed_type: "ebay", is_active: true, is_mobile: false, country_code: "GB"})
    Repo.insert!(%Feed{feed_type: "ebay", is_active: true, is_mobile: true,  country_code: "GB"})
    Repo.insert!(%Feed{feed_type: "ebay", is_active: true, is_mobile: false, country_code: "AU"})
    Repo.insert!(%Feed{feed_type: "ebay", is_active: true, is_mobile: true,  country_code: "AU"})
  end

  def mock_publishers do
    p = Repo.insert!(%Publisher{name: "Panda"})
    p = Repo.insert!(%Publisher{name: "Avast"})
    p = Repo.insert!(%Publisher{name: "Symantec"})
  end
end

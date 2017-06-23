defmodule Apientry.Fixtures do
  alias Apientry.{Publisher, TrackingId, Repo}

  def mock_publishers do
    p = Repo.insert!(%Publisher{name: "Panda"})
    p = Repo.insert!(%Publisher{name: "Avast"})
    p = Repo.insert!(%Publisher{name: "Symantec"})
  end
end

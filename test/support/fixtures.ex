defmodule Apientry.Fixtures do
  alias Apientry.{Publisher, Repo}

  def mock_publishers do
    Repo.insert!(%Publisher{name: "Panda"})
    Repo.insert!(%Publisher{name: "Avast"})
    Repo.insert!(%Publisher{name: "Symantec"})
  end
end

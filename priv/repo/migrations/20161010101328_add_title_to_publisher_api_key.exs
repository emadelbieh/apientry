defmodule Apientry.Repo.Migrations.AddTitleToPublisherApiKey do
  use Ecto.Migration

  def change do
    alter table(:publisher_api_keys) do
      add :title, :string
    end
  end
end

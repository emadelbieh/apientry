defmodule Apientry.Repo.Migrations.AddVisualSearchToPubliserSubIds do
  use Ecto.Migration

  def change do
    alter table(:publisher_sub_ids) do
      add :visual_search, :boolean, default: false
    end
  end
end

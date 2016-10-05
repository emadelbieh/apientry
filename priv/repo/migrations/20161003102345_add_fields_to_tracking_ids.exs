defmodule Apientry.Repo.Migrations.AddFieldsToTrackingIds do
  use Ecto.Migration

  def change do
    alter table(:tracking_ids) do
      add :ebay_api_key_id, references(:ebay_api_keys, on_delete: :nothing)
      add :publisher_api_key_id, references(:publisher_api_keys, on_delete: :nothing)
    end
  end
end

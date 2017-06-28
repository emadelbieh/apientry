defmodule Apientry.Repo.Migrations.AddPublisherIdReferenceToTrackingId do
  use Ecto.Migration

  def change do
    alter table(:tracking_ids) do
      add :publisher_sub_id_id, references(:publisher_sub_ids)
    end
  end
end

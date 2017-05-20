defmodule Apientry.Repo.Migrations.AddSubplacementToTrackingIds do
  use Ecto.Migration

  def change do
    alter table(:tracking_ids) do
      add :subplacement, :string
    end
  end
end

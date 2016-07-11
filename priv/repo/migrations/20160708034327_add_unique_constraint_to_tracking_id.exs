defmodule Apientry.Repo.Migrations.AddUniqueConstraintToTrackingId do
  use Ecto.Migration

  def change do
    create unique_index(:tracking_ids, [:code])
  end
end

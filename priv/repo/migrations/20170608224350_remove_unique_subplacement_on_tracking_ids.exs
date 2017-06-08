defmodule Apientry.Repo.Migrations.RemoveUniqueSubplacementOnTrackingIds do
  use Ecto.Migration

  def change do
    drop index(:tracking_ids, [:subplacement])
  end
end

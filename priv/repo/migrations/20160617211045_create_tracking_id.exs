defmodule Apientry.Repo.Migrations.CreateTrackingId do
  use Ecto.Migration

  def change do
    create table(:tracking_ids) do
      add :code, :string
      add :publisher_id, references(:publishers, on_delete: :nothing)

      timestamps
    end
    create index(:tracking_ids, [:publisher_id])

  end
end

defmodule Apientry.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :geo_id, references(:geos, on_delete: :nothing)

      timestamps()
    end
    create index(:accounts, [:geo_id])
    create unique_index(:accounts, [:name])
  end
end

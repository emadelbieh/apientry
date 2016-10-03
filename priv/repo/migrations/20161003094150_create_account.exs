defmodule Apientry.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account) do
      add :name, :string
      add :geo_id, references(:geos, on_delete: :nothing)

      timestamps()
    end
    create index(:account, [:geo_id])

  end
end

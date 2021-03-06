defmodule Apientry.Repo.Migrations.CreateGeo do
  use Ecto.Migration

  def change do
    create table(:geos) do
      add :name, :string

      timestamps()
    end

    create unique_index(:geos, [:name])
  end
end

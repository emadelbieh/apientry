defmodule Apientry.Repo.Migrations.CreateBlacklist do
  use Ecto.Migration

  def change do
    create table(:blacklists) do
      add :blacklist_type, :string
      add :value, :string
      add :publisher_sub_id, references(:publisher_sub_ids, on_delete: :nothing)

      timestamps()
    end
    create index(:blacklists, [:publisher_sub_id])

  end
end

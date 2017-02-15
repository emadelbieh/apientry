defmodule Apientry.Repo.Migrations.CreatePublisherSubId do
  use Ecto.Migration

  def change do
    create table(:publisher_sub_ids) do
      add :sub_id, :string
      add :publisher_id, references(:publishers, on_delete: :nothing)

      timestamps()
    end
    create index(:publisher_sub_ids, [:publisher_id])

  end
end

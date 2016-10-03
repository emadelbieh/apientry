defmodule Apientry.Repo.Migrations.CreatePublisherApiKey do
  use Ecto.Migration

  def change do
    create table(:publisher_api_keys) do
      add :value, :string
      add :publisher_id, references(:publishers, on_delete: :nothing)

      timestamps()
    end
    create index(:publisher_api_keys, [:publisher_id])

  end
end

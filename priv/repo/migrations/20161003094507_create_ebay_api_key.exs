defmodule Apientry.Repo.Migrations.CreateEbayApiKey do
  use Ecto.Migration

  def change do
    create table(:ebay_api_keys) do
      add :value, :string
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end
    create index(:ebay_api_keys, [:account_id])

  end
end

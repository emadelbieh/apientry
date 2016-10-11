defmodule Apientry.Repo.Migrations.AddTitleToEbayApiKeys do
  use Ecto.Migration

  def change do
    alter table(:ebay_api_keys) do
      add :title, :string
    end
  end
end

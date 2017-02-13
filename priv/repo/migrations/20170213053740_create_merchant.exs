defmodule Apientry.Repo.Migrations.CreateMerchant do
  use Ecto.Migration

  def change do
    create table(:merchants) do
      add :feeds4_id, :string
      add :merchant, :string
      add :slug, :string
      add :website, :string
      add :domain, :string
      add :url, :string
      add :network, :string
      add :country, :string
      add :logo, :string

      timestamps()
    end

  end
end

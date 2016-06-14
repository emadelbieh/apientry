defmodule Apientry.Repo.Migrations.CreateFeed do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :feed_type, :string
      add :is_mobile, :boolean, default: false
      add :is_active, :boolean, default: false
      add :country_code, :string
      add :api_key, :string

      timestamps
    end

  end
end

defmodule Apientry.Repo.Migrations.AddUniqueConstraintToFeed do
  use Ecto.Migration

  def change do
    create unique_index(:feeds, [:country_code, :is_mobile])
  end
end

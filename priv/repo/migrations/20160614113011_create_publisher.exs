defmodule Apientry.Repo.Migrations.CreatePublisher do
  use Ecto.Migration

  def change do
    create table(:publishers) do
      add :name, :string
      add :api_key, :string

      timestamps
    end

  end
end

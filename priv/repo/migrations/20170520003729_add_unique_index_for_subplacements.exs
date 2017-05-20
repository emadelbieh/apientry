defmodule Apientry.Repo.Migrations.AddUniqueIndexForSubplacements do
  use Ecto.Migration

  def change do
    create unique_index(:tracking_ids, [:subplacement])
  end
end

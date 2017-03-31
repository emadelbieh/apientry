defmodule Apientry.Repo.Migrations.AddReferenceData do
  use Ecto.Migration

  def change do
    alter table(:publisher_sub_ids) do
      add :reference_data, :string
    end
  end
end

defmodule Apientry.Repo.Migrations.AddRevenueShareToPublisher do
  use Ecto.Migration

  def change do
    alter table(:publishers) do
      add :revenue_share, :float
    end
  end
end

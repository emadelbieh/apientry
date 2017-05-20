defmodule Apientry.Repo.Migrations.AddReportReceiversToPublishers do
  use Ecto.Migration

  def change do
    alter table(:publishers) do
      add :report_receivers, :string
    end
  end
end

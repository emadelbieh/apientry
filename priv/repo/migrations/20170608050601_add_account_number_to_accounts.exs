defmodule Apientry.Repo.Migrations.AddAccountNumberToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :account_number, :string
    end
  end
end

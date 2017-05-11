defmodule Apientry.Repo.Migrations.CreateCouponCopy do
  use Ecto.Migration

  def change do
    create table(:coupon_copies) do
      add :merchant, :string
      add :merchantid, :string
      add :offer, :string
      add :restriction, :string
      add :url, :string
      add :code, :string
      add :startdate, :string
      add :enddate, :string
      add :category, :string
      add :dealtype, :string
      add :holiday, :string
      add :network, :string
      add :rating, :string
      add :country, :string
      add :logo, :string
      add :website, :string
      add :domain, :string
      add :lastmodified, :string

      timestamps()
    end

  end
end

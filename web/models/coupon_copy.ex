defmodule Apientry.CouponCopy do
  use Apientry.Web, :model

  schema "coupon_copies" do
    field :merchant, :string
    field :merchantid, :string
    field :offer, :string
    field :restriction, :string
    field :url, :string
    field :code, :string
    field :startdate, :string
    field :enddate, :string
    field :category, :string
    field :dealtype, :string
    field :holiday, :string
    field :network, :string
    field :rating, :string
    field :country, :string
    field :logo, :string
    field :website, :string
    field :domain, :string
    field :lastmodified, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:merchant, :merchantid, :offer, :restriction, :url, :code, :startdate, :enddate, :category, :dealtype, :holiday, :network, :rating, :country, :logo, :website, :domain, :lastmodified])
    |> validate_required([:id, :merchant, :merchantid, :url, :code, :startdate, :enddate, :category, :dealtype, :holiday, :network, :rating, :country, :logo, :website, :domain, :lastmodified])
  end
end

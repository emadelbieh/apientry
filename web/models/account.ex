defmodule Apientry.Account do
  use Apientry.Web, :model

  schema "accounts" do
    field :name, :string
    belongs_to :geo, Apientry.Geo
    has_many :ebay_api_keys, Apientry.EbayApiKey

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :geo_id])
    |> validate_required([:name, :geo_id])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:geo_id)
  end
end

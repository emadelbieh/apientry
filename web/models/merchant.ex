defmodule Apientry.Merchant do
  use Apientry.Web, :model

  schema "merchants" do
    field :merchant, :string
    field :slug, :string
    field :website, :string
    field :domain, :string
    field :url, :string
    field :network, :string
    field :country, :string
    field :logo, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :merchant, :slug, :website, :domain, :url, :network, :country, :logo])
    |> validate_required([:id, :merchant, :slug, :website, :domain, :url, :network, :country, :logo])
  end
end

defmodule Apientry.Account do
  use Apientry.Web, :model

  schema "account" do
    field :name, :string
    belongs_to :geo, Apientry.Geo

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end

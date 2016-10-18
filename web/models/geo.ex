defmodule Apientry.Geo do
  use Apientry.Web, :model

  schema "geos" do
    field :name, :string
    has_many :accounts, Apientry.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end

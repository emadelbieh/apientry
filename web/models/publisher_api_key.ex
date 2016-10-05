defmodule Apientry.PublisherApiKey do
  use Apientry.Web, :model

  schema "publisher_api_keys" do
    field :value, :string
    belongs_to :publisher, Apientry.Publisher

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value])
    |> validate_required([:value])
    |> unique_constraint(:value)
  end
end

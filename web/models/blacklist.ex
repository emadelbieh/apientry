defmodule Apientry.Blacklist do
  use Apientry.Web, :model

  schema "blacklists" do
    field :blacklist_type, :string
    field :value, :string
    belongs_to :publisher_sub, Apientry.PublisherSub

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:blacklist_type, :value])
    |> validate_required([:blacklist_type, :value])
  end
end

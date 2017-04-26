defmodule Apientry.Blacklist do
  use Apientry.Web, :model

  schema "blacklists" do
    field :blacklist_type, :string
    field :value, :string
    belongs_to :publisher_sub_id, Apientry.PublisherSubId

    field :all, :boolean, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:publisher_sub_id_id, :blacklist_type, :value])
    |> validate_required([:publisher_sub_id_id, :blacklist_type, :value])
  end
end

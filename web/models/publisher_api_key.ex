defmodule Apientry.PublisherApiKey do
  use Apientry.Web, :model

  schema "publisher_api_keys" do
    field :value, :string
    belongs_to :publisher, Apientry.Publisher
    has_many :tracking_ids, Apientry.TrackingId

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :publisher_id])
    |> validate_required([:value, :publisher_id])
    |> unique_constraint(:value)
    |> foreign_key_constraint(:publisher_id)
  end
end

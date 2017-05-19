defmodule Apientry.Publisher do
  use Apientry.Web, :model

  schema "publishers" do
    field :name, :string
    field :revenue_share, :float

    has_many :api_keys, Apientry.PublisherApiKey
    has_many :tracking_ids, Apientry.TrackingId

    timestamps
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :revenue_share])
    |> validate_required([:name, :revenue_share])
  end
end

defmodule Apientry.Publisher do
  use Apientry.Web, :model

  schema "publishers" do
    field :name, :string
    field :revenue_share, :float
    field :report_receivers, :string

    has_many :api_keys, Apientry.PublisherApiKey
    has_many :tracking_ids, Apientry.TrackingId

    timestamps
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :revenue_share, :report_receivers])
    |> validate_required([:name, :revenue_share])
  end
end

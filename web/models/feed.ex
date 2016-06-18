defmodule Apientry.Feed do
  use Apientry.Web, :model

  schema "feeds" do
    field :feed_type, :string
    field :is_mobile, :boolean, default: false
    field :is_active, :boolean, default: true
    field :country_code, :string
    field :api_key, :string

    has_many :publisher_feeds, Apientry.PublisherFeed
    has_many :publishers, through: [:publisher_feeds, :publisher]

    timestamps
  end

  @required_fields ~w(is_active is_mobile country_code api_key)
  @optional_fields ~w(feed_type)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

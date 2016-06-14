defmodule Apientry.PublisherFeed do
  use Apientry.Web, :model

  schema "publisher_feeds" do
    belongs_to :publisher, Apientry.Publisher
    belongs_to :feed, Apientry.Feed

    timestamps
  end

  @required_fields ~w(publisher_id feed_id)
  @optional_fields ~w()

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

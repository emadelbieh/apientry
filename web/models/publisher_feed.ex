defmodule Apientry.PublisherFeed do
  use Apientry.Web, :model

  schema "publisher_feeds" do
    belongs_to :publisher, Apientry.Publisher
    belongs_to :feed, Apientry.Feed

    timestamps
  end

  @fields [:publisher_id, :feed_id]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end

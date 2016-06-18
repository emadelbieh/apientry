defmodule Apientry.TrackingId do
  use Apientry.Web, :model

  schema "tracking_ids" do
    field :code, :string
    belongs_to :publisher, Apientry.Publisher

    timestamps
  end

  @required_fields ~w(code publisher_id)
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

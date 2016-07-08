defmodule Apientry.TrackingId do
  use Apientry.Web, :model

  schema "tracking_ids" do
    field :code, :string
    belongs_to :publisher, Apientry.Publisher

    timestamps
  end

  @fields [:code, :publisher_id]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:code, name: :tracking_ids_code_index)
  end
end

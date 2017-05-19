defmodule Apientry.Publisher do
  use Apientry.Web, :model

  schema "publishers" do
    field :name, :string
    field :revenue_share, :float

    has_many :api_keys, Apientry.PublisherApiKey
    has_many :tracking_ids, Apientry.TrackingId

    timestamps
  end

  @fields [:name, :api_key]
  @required [:name]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@required)
    |> generate_api_key()
  end

  def api_key_changeset(model) do
    model
    |> cast(%{}, [])
    |> generate_api_key()
  end

  def generate_api_key(changeset) do
    case changeset.valid? do
      true -> put_change(changeset, :api_key, Ecto.UUID.generate)
      _ -> changeset
    end
  end
end

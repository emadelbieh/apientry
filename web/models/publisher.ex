defmodule Apientry.Publisher do
  use Apientry.Web, :model

  schema "publishers" do
    field :name, :string
    field :api_key, :string

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(api_key)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> generate_api_key()
  end

  def api_key_changeset(model) do
    model
    |> cast(%{}, [], [])
    |> generate_api_key()
  end

  def generate_api_key(changeset) do
    case changeset.valid? do
      true -> put_change(changeset, :api_key, Ecto.UUID.generate)
      _ -> changeset
    end
  end
end

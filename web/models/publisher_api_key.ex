defmodule Apientry.PublisherApiKey do
  use Apientry.Web, :model

  schema "publisher_api_keys" do
    field :title, :string
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
    |> cast(trim_value(params), [:title, :value, :publisher_id])
    |> validate_required([:title, :value, :publisher_id])
    |> unique_constraint(:value)
    |> foreign_key_constraint(:publisher_id)
  end

  def sorted(query) do
    from p in query, order_by: p.value
  end

  def values_and_ids(query) do
    from p in query, select: {p.title, p.id}
  end

  def names_and_ids(query) do
    from p in query, select: {p.name, p.id}
  end

  defp trim_value(params) do
    case params["value"] do
      nil -> params
      value -> Map.put(params, "value", String.trim(value))
    end
  end

  def value_changeset(model) do
    model
    |> cast(%{}, [])
    |> generate_api_key()
  end

  def generate_api_key(changeset) do
    case changeset.valid? do
      true -> put_change(changeset, :value, Ecto.UUID.generate)
      _ -> changeset
    end
  end
end

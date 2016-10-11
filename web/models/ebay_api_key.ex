defmodule Apientry.EbayApiKey do
  use Apientry.Web, :model

  schema "ebay_api_keys" do
    field :title, :string
    field :value, :string

    belongs_to :account, Apientry.Account
    has_many :tracking_ids, Apientry.TrackingId

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :value, :account_id])
    |> validate_required([:title, :value, :account_id])
    |> unique_constraint(:value)
    |> foreign_key_constraint(:account_id)
  end

  def sorted(query) do
    from e in query, order_by: e.value
  end

  def values_and_ids(query) do
    from e in query, select: {e.value, e.id}
  end

end

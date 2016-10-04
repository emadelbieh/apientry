defmodule Apientry.EbayApiKey do
  use Apientry.Web, :model

  schema "ebay_api_keys" do
    field :value, :string
    belongs_to :account, Apientry.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :account_id])
    |> validate_required([:value, :account_id])
    |> unique_constraint(:value)
    |> foreign_key_constraint(:account_id)
  end
end

defmodule Apientry.TrackingId do
  use Apientry.Web, :model

  schema "tracking_ids" do
    field :subplacement, :string
    field :code, :string

    belongs_to :ebay_api_key, Apientry.EbayApiKey
    belongs_to :publisher_api_key, Apientry.PublisherApiKey
    belongs_to :publisher_sub_id, Apientry.PublisherSubId

    has_one :geo, through: [:ebay_api_key, :account, :geo]

    timestamps
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(trim_code(params), [:subplacement, :code, :ebay_api_key_id, :publisher_api_key_id])
    |> validate_required([:subplacement, :code, :ebay_api_key_id])
    |> unique_constraint(:code, name: :tracking_ids_code_index)
  end

  def with_ids(ids) do
    from(t in __MODULE__, where: t.id in ^ids)
  end

  defp trim_code(params) do
    case params["code"] do
      nil -> params
      code -> Map.put(params, "code", String.trim(code))
    end
  end
end

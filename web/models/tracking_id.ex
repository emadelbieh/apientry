defmodule Apientry.TrackingId do
  use Apientry.Web, :model

  schema "tracking_ids" do
    field :code, :string
    belongs_to :ebay_api_key, Apientry.EbayApiKey
    belongs_to :publisher_api_key, Apientry.PublisherApiKey

    # TODO: kept for legacy data
    belongs_to :publisher, Apientry.Publisher

    timestamps
  end

  @fields [:code, :ebay_api_key_id]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(trim_code(params), [:code, :ebay_api_key_id, :publisher_api_key_id])
    |> validate_required([:code, :ebay_api_key_id])
    |> unique_constraint(:code, name: :tracking_ids_code_index)
  end

  def legacy_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:code, :ebay_api_key_id, :publisher_api_key_id, :publisher_id])
    |> validate_required([:code, :ebay_api_key_id])
    |> unique_constraint(:code, name: :tracking_ids_code_index)
  end

  defp trim_code(params) do
    case params["code"] do
      nil -> params
      code -> Map.put(params, "code", String.trim(code))
    end
  end
end

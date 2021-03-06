defmodule Apientry.PublisherSubId do
  use Apientry.Web, :model

  schema "publisher_sub_ids" do
    field :sub_id, :string
    field :visual_search, :boolean
    field :reference_data, :string
    belongs_to :publisher, Apientry.Publisher

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:sub_id, :publisher_id, :visual_search, :reference_data])
    |> validate_required([:sub_id])
  end
end

defmodule Apientry.EbayTransformer do
  @moduledoc """
  Transforms JSON or XML.

  See `Apientry.EbayJsonTransformer`.
  """

  alias Apientry.EbayJsonTransformer

  def transform(data, assigns, "json" = _format) do
    data
    |> EbayJsonTransformer.transform(assigns)
  end

  def transform(data, _assigns, _format) do
    # XML not supported
    data
  end
end

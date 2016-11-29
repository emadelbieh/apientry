defmodule Apientry.EbayTransformer do
  @moduledoc """
  Transforms JSON or XML.

  See `Apientry.EbayJsonTransformer`.
  See `Apientry.EbayXmlTransformer`.
  """

  alias Apientry.EbayJsonTransformer
  alias Apientry.EbayXmlTransformer

  def transform(data, assigns, "json" = _format) do
    data
    |> EbayJsonTransformer.transform(assigns)
  end

  def transform(data, assigns, "xml") do
    result = data
    |> EbayJsonTransformer.transform(assigns)
    |> EbayXmlTransformer.transform
  end

  def transform(data, _assigns, _format) do
    # unsupported format
    data
  end
end

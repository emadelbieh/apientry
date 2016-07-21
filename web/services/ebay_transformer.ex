defmodule Apientry.EbayTransformer do
  @moduledoc """
  Transforms JSON or XML.

  See `Apientry.EbayJsonTransformer`.
  """

  alias Apientry.EbayJsonTransformer

  def transform(data, assigns, "json" = _format) do
    data
    |> Poison.decode!()
    |> EbayJsonTransformer.transform(assigns)
    |> Poison.encode!()
  end

  def transform(data, _assigns, _format) do
    # XML not supported
    data
  end
end

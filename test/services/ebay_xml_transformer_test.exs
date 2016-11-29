defmodule Apientry.EbayXmlTransformerTest do
  use ExUnit.Case

  alias Apientry.EbayXmlTransformer

  test "transforms an object" do
    json = %{"key" => "value"}
    result = EbayXmlTransformer.transform(json)
    assert result == {"result", %{}, [{"key", %{}, "value"}]}
  end

  test "transforms an array of objects" do
    json = %{"keys" => [%{"key" => "value"}]}
    result = EbayXmlTransformer.transform(json)
    assert result == {"result", %{}, [{"keys", %{type: "array"}, [{"key", %{}, "value"}]}]}
  end

  test "transforms an array of strings" do
    json = %{"upc" => ["1234567890", "0987654321"]}
    result = EbayXmlTransformer.transform(json)
    assert result == {"result", %{}, [{"upc", %{type: "array"}, [{"upc", %{}, "1234567890"}, {"upc", %{}, "0987654321"}]}]}
  end
end

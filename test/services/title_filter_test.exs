defmodule Apientry.TitleFilterTest do
  use ExUnit.Case

  alias Apientry.TitleFilter

  @product %{
    "name" => "Nike Revolution 3 Men's Shoes"
  }

  @body_with_duplicate_titles %{
    "categories" => %{ "category" => [%{
      "items" => %{ "item" => [
         %{ "product" => @item },
         %{ "offer"   => @item } 
      ]}
    }]
  }}

  @body_with_duplicates_removed %{
    "categories" => %{ "category" => [%{
      "items" => %{ "item" => [
         %{ "product" => @item }
      ]}
    }]
  }}

  test "filter_duplicate removes duplicate title from items" do
    result = TitleFilter.filter_duplicate_title(@body_with_duplicate_titles)
    assert result == @body_with_duplicates_removed
  end
end

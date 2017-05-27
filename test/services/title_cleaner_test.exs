defmodule Apientry.TitleCleanerTest do
  use ExUnit.Case

  alias Apientry.TitleCleaner, as: TC

  test "clean removes ellipses" do
    assert TC.clean("This is ... a keyword") == "this is a keyword"
  end

  test "clean removes dashes" do
    assert TC.clean("This is - a keyword") == "this is a keyword"
  end

  test "clean removes slashes" do
    assert TC.clean("This is / a / keyword") == "this is a keyword"
  end

  test "clean collapses multiple spaces" do
    assert TC.clean("This   is    a  keyword") == "this is a keyword"
  end

  test "clean removes copyright symbols" do
    assert TC.clean("This™   is © a keyword®") == "this is a keyword"
  end

  test "clean removes stopwords" do
    assert TC.clean("This avec offres spéciales is fiyatı a keyword undefined") == "this is a keyword "
  end
end

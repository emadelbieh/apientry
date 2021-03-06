defmodule Apientry.StoreFilterTest do
  use ExUnit.Case

  alias Apientry.StoreFilter

  test "shopping.com matches both Ebay and Shopping" do
    assert StoreFilter.matches?("shopping.com", "Ebay") &&
      StoreFilter.matches?("shopping.com", "Shopping.com")
  end

  test "ebay.com matches both Shopping and Ebay" do
    assert StoreFilter.matches?("ebay.com", "Shopping.com") &&
      StoreFilter.matches?("ebay.com", "Ebay.com")
  end

  test "walmart.com matches Walmart" do
    assert StoreFilter.matches?("walmart.com", "Walmart.com")
  end

  test "www.walmart.com matches Walmart" do
    assert StoreFilter.matches?("www.walmart.com", "Walmart.com")
  end

  test "www.kohls.com matches Kohl's" do
    assert StoreFilter.matches?("www.kohls.com", "Kohl's")
  end

  test "kohls.com matches Kohl's" do
    assert StoreFilter.matches?("kohls.com", "Kohl's")
  end
end

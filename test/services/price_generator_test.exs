defmodule Apientry.PriceGeneratorTest do
  use ExUnit.Case

  alias Apientry.PriceGenerator

  test "get_min_max returns price padding of 50% for prices > 0 but < 30" do
    assert PriceGenerator.get_min_max(25) == [12.50, 37.50]
  end

  test "get_min_max returns price padding of 35% for prices > 30 but < 100" do
    assert PriceGenerator.get_min_max(50) == [32.50, 67.50]
  end

  test "get_min_max returns price padding of 25% for prices > 100 but < 500" do
    assert PriceGenerator.get_min_max(150) == [112.50, 187.50]
  end

  test "get_min_max returns price padding of 15% for prices > 500" do
    assert PriceGenerator.get_min_max(3999) == [3399.15, 4598.85]
  end

  test "get_min_max returns minimum lower bound of 0 and minimum higher bound of 15" do
    assert PriceGenerator.get_min_max(0) == [0.00, 15.00]
  end
end

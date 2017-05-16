defmodule Apientry.PriceCleanerTest do
  use ExUnit.Case

  alias Apientry.PriceCleaner

  test "clean can parse european cents" do
    result = PriceCleaner.clean("234€55")
    assert(result == 234.55)
  end

  test "clean can parse european prices greater than a thousand euros" do
    result = PriceCleaner.clean("789.123.456,78 €")
    assert(result == 789_123_456.78)
  end

  test "clean can parse european prices appended with EUR" do
    result = PriceCleaner.clean("789.123.456,78 EUR")
    assert(result == 789_123_456.78)
  end

  test "clean can parse european price format with £ symbol" do
    result = PriceCleaner.clean("£ 789.123.456,78")
    assert(result == 789_123_456.78)
  end

  test "clean can parse american price format with $ symbol" do
    result = PriceCleaner.clean("$789.123.456,78")
    assert(result == 789_123_456.78)
  end

  test "clean can parse american price format prepended with USD" do
    result = PriceCleaner.clean("USD 789.123.456,78")
    assert(result == 789_123_456.78)
  end

  test "clean only parses the lower bound of a price range - USD" do
    result = PriceCleaner.clean("$125.00 - $345.00")
    assert(result == 125.00)
  end

  test "clean only parses the lower bound of a price range - EUR" do
    result = PriceCleaner.clean("125.00 € - 345.00 €")
    assert(result == 125.00)
  end
end

defmodule Apientry.ImageTrackerTest do
  use ExUnit.Case, async: true

  test "remove_keys removes unwanted kv pair from a map" do
    input  = %{"a": "a", "b": "b", "c": "c", "d": "d"}
    output = %{c: "c", d: "d"}

    assert Apientry.ImageTracker.remove_keys(input, ~w[a b]a) == output
  end
end

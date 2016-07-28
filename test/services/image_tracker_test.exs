defmodule Apientry.ImageTrackerTest do
  use ExUnit.Case

  alias Apientry.ImageTracker

  @body %{"categories" => %{"category" => [%{"items" => %{"item" => [%{"offer" => %{"imageList" => %{"image" => [%{"sourceURL" => "http://google.com"}, %{"sourceURL" => "http://yahoo.com"}]}}}, %{"offer" => %{"imageList" => %{"image" => [%{"sourceURL" => "http://google.com"}, %{"sourceURL" => "http://yahoo.com"}]}}}]}}]}}

  test "extract_urls extracts image urls from the decoded body" do
    assert ImageTracker.extract_urls(@body) == ["http://google.com", "http://yahoo.com", "http://google.com", "http://yahoo.com"]
  end
end

defmodule Apientry.ImageTrackerTest do
  use ExUnit.Case, async: true

  alias Apientry.ImageTracker

  @body %{"categories" => %{"category" => [%{"items" => %{"item" => [
              %{"offer" => %{"imageList" => %{"image" => [%{"sourceURL" => "http://google.com"}, %{"sourceURL" => "http://yahoo.com"}]}}},
              %{"offer" => %{"imageList" => %{"image" => [%{"sourceURL" => "http://google.com"}, %{"sourceURL" => "http://yahoo.com"}]}}}]}}]}}

  @body_with_missing_offer %{"categories" => %{"category" => [%{"items" => %{"item" => [
              %{},
              %{"offer" => %{"imageList" => %{"image" => [%{"sourceURL" => "http://google.com"}, %{"sourceURL" => "http://yahoo.com"}]}}}]}}]}}

  test "get_image_urls extracts image urls from the decoded body" do
    urls = ImageTracker.get_image_urls(@body)
    assert urls == ["http://google.com", "http://yahoo.com", "http://google.com", "http://yahoo.com"]
  end

  test "get_image_urls extracts image urls from the decoded body with missing offers" do
    urls = ImageTracker.get_image_urls(@body_with_missing_offer)
    assert urls == ["http://google.com", "http://yahoo.com"]
  end
end

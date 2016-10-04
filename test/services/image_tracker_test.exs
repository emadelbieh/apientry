defmodule Apientry.ImageTrackerTest do
  use ExUnit.Case, async: true

  alias Apientry.ImageTracker

  @body %{"categories" => %{"category" => [%{"items" => %{"item" => [
              %{"product" => %{"images" => %{"image" => [%{"sourceURL" => "http://google.com"}, %{"sourceURL" => "http://yahoo.com"}]}}},
              %{"product" => %{"images" => %{"image" => [%{"sourceURL" => "http://google.com"}, %{"sourceURL" => "http://yahoo.com"}]}}}]}}]}}

  @body_with_exceptions %{"exceptions" => %{"exception" => [%{"code" => 28, "message" => "GeneralSearch requires either a product, an offer, a merchant id, a UPC, a leaf-level category, or a keyword.", "type" => "error"}, %{"code" => 1001, "message" => "Empty term ignored", "type" => "warning"}], "exceptionCount" => 2}, "serverDetail" => %{"apiEnv" => "prod", "apiVersion" => "r116.2016.sprint14", "buildNumber" => "5", "buildTimestamp" => "Partner_API-r116.2016.sprint14-5 2016-07-18 22:50:53", "requestId" => "p8.6a439ab22edce30e6f83", "timestamp" => "2016-08-03T02:21:27.824+0000"}}

  test "get_image_urls extracts image urls from the decoded body" do
    urls = ImageTracker.get_image_urls(@body)
    assert urls == ["http://google.com", "http://yahoo.com", "http://google.com", "http://yahoo.com"]
  end

  test "get_image_urls returns an empty list when body contains exceptions" do
    urls = ImageTracker.get_image_urls(@body_with_exceptions)
    assert urls == []
  end
end

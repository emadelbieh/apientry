defmodule Apientry.EbayJsonTransformerTest do
  use Apientry.ConnCase, async: true

  alias Apientry.EbayJsonTransformer

  @redirect_base "https://sandbox.apientry.com/redirect/"
  @category_url "http://www.xyz.com/camera-lenses/nikon/products?oq=nikon&linkin_id=8094918"
  @ebay_category_url "http://www.shopping.com/camera-lenses/nikon/products?oq=nikon&linkin_id=8094918"
  @ebay_offer_url "http://rover.ebay.com/rover/13/0/19/DealFrame/DealFrame.cmp?bm=222&BEFID=96323&aon=%5E1&MerchantID=6201&crawler_id=6201&dealId=I5GqWCz_Dxeyilo9jj06YQ%3D%3D&url=https%3A%2F%2Fwww.42photo.com%2FProduct%2Fnikon-70-200mm-f-2-8g-af-s-ed-vr-ii-zoom-lens-77mm%2F92703&linkin_id=8094918&Issdt=160711052619&searchID=p24.ea21531013086131c1d6&DealName=Nikon+70-200mm+f%2F2.8G+AF-S+ED+VR+II+Zoom+Lens+%2877mm%29&dlprc=1949.0&AR=1&NG=1&NDP=5&PN=1&ST=7&FPT=DSP&NDS=&NMS=&MRS=&PD=95870214&brnId=14763&IsFtr=0&IsSmart=0&op=&CM=&RR=1&IsLps=0&code=&acode=153&category=&HasLink=&ND=&MN=&GR=&lnkId=&SKU=JAA807DA&IID=&MEID="
  @keyword "nikon camera"
  @ip_address "8.8.8.8"
  @is_mobile true
  @country "US"
  @browser "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
  @domain "myshoppingsite.com"

  @assigns %{
    is_mobile: @is_mobile,
    country: @country,
    redirect_base: @redirect_base,
    params: %{
      "keyword" => @keyword,
      "visitorIPAddress" => @ip_address,
      "visitorUserAgent" => @browser,
      "domain" => @domain
    }
  }

  test "transform categoryURL" do
    data = %{
      "categories" => %{
        "category" => [
          %{
            "name" => "Camera Lenses",
            "categoryURL" => @category_url
          }
        ]
      }
    }

    result = EbayJsonTransformer.transform(data, @assigns)

    url = Enum.at(result["categories"]["category"], 0)["categoryURL"]
    url_data = decode_url(url)

    assert url_data["event"] == "CLICK_CATEGORY_URL"
    assert url_data["link"] == @category_url
    assert url_data["country_code"] == @country
    assert url_data["domain"] == "www.xyz.com"
    assert url_data["ip_address"] == @ip_address
    assert url_data["is_mobile"] == to_string(@is_mobile)
    assert url_data["request_domain"] == @domain
    assert url_data["result_keyword"] == @keyword
    assert url_data["user_agent"] == @browser
    assert url_data["category_name"] == "Camera Lenses"
  end

  test "transform offerURL" do
    data = %{
      "categories" => %{
        "category" => [
          %{
            "name" => "Camera Lenses",
            "categoryURL" => @category_url,
            "items" => %{
              "item" => [
                %{
                  "offer" => %{
                    "name" => "AF Lens",
                    "manufacturer" => "Nikon",
                    "offerURL" => @ebay_offer_url,
                    "used" => false,
                    "basePrice" => %{
                      "value" => "912.00",
                      "currency" => "USD"
                    },
                    "stockStatus" => "in-stock"
                  }
                }
              ]
            }
          }
        ]
      }
    }

    result = EbayJsonTransformer.transform(data, @assigns)

    cat = Enum.at(result["categories"]["category"], 0)
    item = Enum.at(cat["items"]["item"], 0)
    offer = item["offer"]
    url = offer["offerURL"]
    url_data = decode_url(url)

    assert url_data["event"] == "CLICK_OFFER_URL"
    assert url_data["link"] == @ebay_offer_url
    assert url_data["country_code"] == @country
    assert url_data["domain"] == "rover.ebay.com"
    assert url_data["ip_address"] == @ip_address
    assert url_data["is_mobile"] == to_string(@is_mobile)
    assert url_data["request_domain"] == @domain
    assert url_data["result_keyword"] == @keyword
    assert url_data["user_agent"] == @browser

    assert url_data["offer_name"] == "AF Lens"
    assert url_data["manufacturer"] == "Nikon"
    assert url_data["used"] == "false"
    assert url_data["price_value"] == "912.00"
    assert url_data["currency"] == "USD"
    assert url_data["stock_status"] == "in-stock"
  end

  test "transform productOffersURL" do
    data = %{
      "categories" => %{
        "category" => [
          %{
            "name" => "Camera Lenses",
            "categoryURL" => @category_url,
            "items" => %{
              "item" => [
                %{
                  "product" => %{
                    "name" => "AF Lens",
                    "onSale" => true,
                    "onSalePercentOff" => "0",
                    "productOffersURL" => @ebay_offer_url,
                    "productSpecsURL" => @ebay_offer_url,
                    "freeShipping" => false,
                    "minPrice" => %{
                      "value" => "912.00"
                    },
                    "maxPrice" => %{
                      "value" => "922.00"
                    },
                  }
                }
              ]
            }
          }
        ]
      }
    }

    result = EbayJsonTransformer.transform(data, @assigns)

    cat = Enum.at(result["categories"]["category"], 0)
    item = Enum.at(cat["items"]["item"], 0)
    product = item["product"]
    url = product["productOffersURL"]
    url_data = decode_url(url)

    assert product["productOffersURL"] == product["productSpecsURL"]

    assert url_data["event"] == "CLICK_PRODUCT_URL"
    assert url_data["link"] == @ebay_offer_url
    assert url_data["country_code"] == @country
    assert url_data["domain"] == "rover.ebay.com"
    assert url_data["ip_address"] == @ip_address
    assert url_data["is_mobile"] == to_string(@is_mobile)
    assert url_data["request_domain"] == @domain
    assert url_data["result_keyword"] == @keyword
    assert url_data["user_agent"] == @browser

    assert url_data["product_name"] == "AF Lens"
    assert url_data["category_name"] == "Camera Lenses"
    assert url_data["on_sale"] == "true" # to_string'd
    assert url_data["on_sale_percent_off"] == "0"
    assert url_data["free_shipping"] == "false"
    assert url_data["minimum_price"] == "912.00"
    assert url_data["maximum_price"] == "922.00"
  end

  test "reject offers in same domain based on store name" do
    data = %{
      "categories" => %{
        "category" => [
          %{
            "name" => "Camera Lenses",
            "categoryURL" => @category_url,
            "items" => %{
              "item" => [
                %{
                  "offer" => %{
                    "store" => %{
                      "trusted" => false,
                      "name" => "Walmart.com"
                    },
                  }
                }
              ]
            }
          }
        ]
      }
    }

    assigns = @assigns
    |> put_in([:params, "domain"], "www.walmart.com")
    result = EbayJsonTransformer.transform(data, assigns)

    cat = Enum.at(result["categories"]["category"], 0)
    item = Enum.at(cat["items"]["item"], 0)
    assert !item

    assert cat["items"]["returnedItemCount"] == 0
  end

  #test "reject categories in same domain based on categoryURL" do
  #  data = %{
  #    "categories" => %{
  #      "category" => [
  #        %{
  #          "name" => "Camera Lenses",
  #          "categoryURL" => "http://www.ebay.com/"
  #        }
  #      ]
  #    }
  #  }

  #  assigns = @assigns
  #  |> put_in([:params, "domain"], "ebay.com")
  #  result = EbayJsonTransformer.transform(data, assigns)

  #  cats = result["categories"]["category"]
  #  assert length(cats) == 0
  #end

  #test "reject offers in same domain based on productOffersURL" do
  #  data = %{
  #    "categories" => %{
  #      "category" => [
  #        %{
  #          "name" => "Camera Lenses",
  #          "categoryURL" => @category_url,
  #          "items" => %{
  #            "item" => [
  #              %{
  #                "product" => %{
  #                  "productOffersURL" => @ebay_offer_url
  #                }
  #              }
  #            ]
  #          }
  #        }
  #      ]
  #    }
  #  }

  #  assigns = @assigns
  #  |> Map.update!(:params, fn params ->
  #    params
  #    |> Map.put("domain", "ebay.com")
  #  end)
  #  result = EbayJsonTransformer.transform(data, assigns)

  #  cat = Enum.at(result["categories"]["category"], 0)
  #  item = Enum.at(cat["items"]["item"], 0)
  #  assert !item
  #end

  #test "reject offers in same domain (passing the root domain)" do
  #  data = %{
  #    "categories" => %{
  #      "category" => [
  #        %{
  #          "name" => "Camera Lenses",
  #          "categoryURL" => @category_url,
  #          "items" => %{
  #            "item" => [
  #              %{
  #                "offer" => %{
  #                  "name" => "AF Lens",
  #                  "manufacturer" => "Nikon",
  #                  "offerURL" => @ebay_offer_url,
  #                  "used" => false,
  #                  "basePrice" => %{
  #                    "value" => "912.00",
  #                    "currency" => "USD"
  #                  },
  #                  "stockStatus" => "in-stock"
  #                }
  #              }
  #            ]
  #          }
  #        }
  #      ]
  #    }
  #  }

  #  assigns = @assigns
  #  |> Map.update!(:params, fn params ->
  #    params
  #    |> Map.put("domain", "ebay.com")
  #  end)
  #  result = EbayJsonTransformer.transform(data, assigns)

  #  cat = Enum.at(result["categories"]["category"], 0)
  #  item = Enum.at(cat["items"]["item"], 0)
  #  assert !item
  #end

  test "transform attributeURL" do
    attribute_url = "http://www.shopping.com/camera-lenses/nikon/products?oq=nikon&linkin_id=8094918"
    attribute_value_url = "http://www.shopping.com/camera-lenses/nikon/products?minPrice=0&maxPrice=5614&linkin_id=8094918"

    data = %{
      "categories" => %{
        "category" => [
          %{
            "name" => "Camera Lenses",
            "categoryURL" => @category_url,
            "attributes" => %{
              "attribute" => [
                %{
                  "name" => "Price range",
                  "attributeURL" => attribute_url,
                  "attributeValues" => %{
                    "attributeValue" => [
                      %{
                        "name" => "$0 - $5614",
                        "attributeValueURL" => attribute_value_url
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }

    result = EbayJsonTransformer.transform(data, @assigns)

    cat = Enum.at(result["categories"]["category"], 0)
    attr = Enum.at(cat["attributes"]["attribute"], 0)

    url = attr["attributeURL"]
    url_data = decode_url(url)

    assert url_data["event"] == "CLICK_ATTRIBUTE_URL"
    assert url_data["link"] == attribute_url
    assert url_data["country_code"] == @country
    assert url_data["domain"] == "www.shopping.com"
    assert url_data["ip_address"] == @ip_address
    assert url_data["is_mobile"] == to_string(@is_mobile)
    assert url_data["request_domain"] == @domain
    assert url_data["result_keyword"] == @keyword
    assert url_data["user_agent"] == @browser

    assert url_data["category_name"] == "Camera Lenses"
    assert url_data["attribute_name"] == "Price range"

    a_value = Enum.at(attr["attributeValues"]["attributeValue"], 0)

    url = a_value["attributeValueURL"]
    url_data = decode_url(url)

    assert url_data["event"] == "CLICK_ATTRIBUTEVALUE_URL"
    assert url_data["link"] == attribute_value_url
    assert url_data["country_code"] == @country
    assert url_data["domain"] == "www.shopping.com"
    assert url_data["ip_address"] == @ip_address
    assert url_data["is_mobile"] == to_string(@is_mobile)
    assert url_data["request_domain"] == @domain
    assert url_data["result_keyword"] == @keyword
    assert url_data["user_agent"] == @browser

    assert url_data["category_name"] == "Camera Lenses"
    assert url_data["attribute_name"] == "Price range"
    assert url_data["attribute_value_name"] == "$0 - $5614"
  end

  test "transform reviewURL" do
    review_url = "http://www.shopping.com/xMR-store_42photo~MRD-6201~S-1~linkin_id-8094918"
    store_name = "Shopping.com"
    trusted = true
    authorized_reseller = false

    data = %{
      "categories" => %{
        "category" => [
          %{
            "name" => "Camera Lenses",
            "categoryURL" => @category_url,
            "items" => %{
              "item" => [
                %{
                  "offer" => %{
                    "name" => "AF Lens",
                    "manufacturer" => "Nikon",
                    "offerURL" => @ebay_offer_url,
                    "used" => false,
                    "basePrice" => %{
                      "value" => "912.00",
                      "currency" => "USD"
                    },
                    "stockStatus" => "in-stock",
                    "store" => %{
                      "name" => store_name,
                      "trusted" => trusted,
                      "authorizedReseller" => authorized_reseller,
                      "ratingInfo" => %{
                        "reviewURL" => review_url
                      }
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }

    result = EbayJsonTransformer.transform(data, @assigns)

    cat = Enum.at(result["categories"]["category"], 0)
    item = Enum.at(cat["items"]["item"], 0)
    store = item["offer"]["store"]
    url = store["ratingInfo"]["reviewURL"]
    url_data = decode_url(url)

    assert url_data["event"] == "CLICK_REVIEW_URL"
    assert url_data["link"] == review_url
    assert url_data["domain"] == "www.shopping.com"
    assert url_data["country_code"] == @country
    assert url_data["ip_address"] == @ip_address
    assert url_data["is_mobile"] == to_string(@is_mobile)
    assert url_data["request_domain"] == @domain
    assert url_data["result_keyword"] == @keyword
    assert url_data["user_agent"] == @browser

    assert url_data["store"] == store_name
    assert url_data["trusted"] == to_string(trusted)
    assert url_data["authorized_reseller"] == to_string(authorized_reseller)
  end

  def decode_url(url) do
    url
    |> String.replace(@redirect_base, "")
    |> Base.url_decode64!()
    |> String.slice(1..-1)
    |> URI.decode_query()
  end
end

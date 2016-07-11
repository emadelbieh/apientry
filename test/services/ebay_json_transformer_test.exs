defmodule Apientry.EbayJsonTransformerTest do
  use Apientry.ConnCase, async: true

  alias Apientry.EbayJsonTransformer

  @redirect_base "https://sandbox.apientry.com/redirect/"
  @category_url "http://www.shopping.com/camera-lenses/nikon/products?oq=nikon&linkin_id=8094918"
  @offer_url "http://rover.ebay.com/rover/13/0/19/DealFrame/DealFrame.cmp?bm=222&BEFID=96323&aon=%5E1&MerchantID=6201&crawler_id=6201&dealId=I5GqWCz_Dxeyilo9jj06YQ%3D%3D&url=https%3A%2F%2Fwww.42photo.com%2FProduct%2Fnikon-70-200mm-f-2-8g-af-s-ed-vr-ii-zoom-lens-77mm%2F92703&linkin_id=8094918&Issdt=160711052619&searchID=p24.ea21531013086131c1d6&DealName=Nikon+70-200mm+f%2F2.8G+AF-S+ED+VR+II+Zoom+Lens+%2877mm%29&dlprc=1949.0&AR=1&NG=1&NDP=5&PN=1&ST=7&FPT=DSP&NDS=&NMS=&MRS=&PD=95870214&brnId=14763&IsFtr=0&IsSmart=0&op=&CM=&RR=1&IsLps=0&code=&acode=153&category=&HasLink=&ND=&MN=&GR=&lnkId=&SKU=JAA807DA&IID=&MEID="
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

    assert url_data["link"] == @category_url
    assert url_data["country_code"] == @country
    assert url_data["domain"] == "www.shopping.com"
    assert url_data["ip_address"] == @ip_address
    assert url_data["is_mobile"] == to_string(@is_mobile)
    assert url_data["request_domain"] == @domain
    assert url_data["result_keyword"] == @keyword
    assert url_data["user_agent"] == @browser
    assert url_data["category_name"] == "Camera Lenses"
  end

  def decode_url(url) do
    url
    |> String.replace(@redirect_base, "")
    |> Base.decode64!()
    |> String.slice(1..-1)
    |> URI.decode_query()
  end
end

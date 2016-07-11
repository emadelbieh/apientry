defmodule Apientry.EbayJsonTransformer do
  @moduledoc """
  Transforms a JSON string based on some request information.

  Transforms given `data` (a JSON string).

      pry> Apientry.EbayJsonTransformer.transform(json_data, assigns)

  ## URL transformations

  For all URL's, they will be rewritten to use the `/redirect/` redirection endpoint.

      - "offerURL": "http://rover.ebay.com/rover/13/0/19/DealFrame/DealFrame.cmp?bm=222&BEFID=96323&aon=%5E1&MerchantID=6201&crawler_id=6201&dealId=I5GqWCz_Dxeyilo9jj06YQ%3D%3D&url=https%3A%2F%2Fwww.42photo.com%2FProduct%2Fnikon-70-200mm-f-2-8g-af-s-ed-vr-ii-zoom-lens-77mm%2F92703&linkin_id=8094918&Issdt=160711052619&searchID=p24.ea21531013086131c1d6&DealName=Nikon+70-200mm+f%2F2.8G+AF-S+ED+VR+II+Zoom+Lens+%2877mm%29&dlprc=1949.0&AR=1&NG=1&NDP=5&PN=1&ST=7&FPT=DSP&NDS=&NMS=&MRS=&PD=95870214&brnId=14763&IsFtr=0&IsSmart=0&op=&CM=&RR=1&IsLps=0&code=&acode=153&category=&HasLink=&ND=&MN=&GR=&lnkId=&SKU=JAA807DA&IID=&MEID=",
      + "offerURL": "http://sandbox.apientry.com/redirect/gyqtNWZmIxTx3b6OxTSALwqjVP9gAanUGFgTA5BRDvyA..."

  The Base64 fragment decodes to a `?` with a query string.

      pry> Base.decode64!("P2xpbms9aHR0cDovL2dvb2dsZS5jb20maXNfbW9iaWxlPXRydWU=")
      "?link=http://google.com&is_mobile=true"

  The query string will have these fields below. See `build_url/3`.

  | Field            | Taken from                           |
  | -----            | ----------                           |
  | `link`           | *(the URL)*                          |
  | `domain`         | *(domain of `link`)*                 |
  | `is_mobile`      | `assigns.is_mobile`                  |
  | `result_keyword` | `assigns.params["keyword"]`          |
  | `ip_address`     | `assigns.params["visitorIPAddress"]` |
  | `country_code`   | `assigns.country`                    |
  | `user_agent`     | `assigns.params["visitorUserAgent"]` |
  | `request_domain` | `assigns.params["domain"]`           |

  In practice, keep note that some of these are inferred.

  - `assigns.country` is inferred from `params["visitorIPAddress"]`
  - `assigns.is_mobile` is inferred from `params["visitorIPAddress"]`

  See `Apientry.Searcher` for details on `assigns`.

  ## Category

  `Category` URL's affect the following:

  - `categories.category[].categoryURL`

  The following fields are added:

  | Field           | Taken from    |
  | -----           | ----------    |
  | `category_name` | category.name |

  ## Offer
  `Offer` URL's cover:

  - `categories.category[].items.item[].offer.offerURL`

  The following fields are added:

  | Field            | Taken from                 |
  | -----            | ----------                 |
  | `offer_name`     | `offer.name`               |
  | `manufacturer`   | `offer.manufacturer`       |
  | `used`           | `offer.used`               |
  | `price_value`    | `offer.basePrice.value`    |
  | `price_currency` | `offer.basePrice.currency` |
  | `stock_status`   | `offer.stockStatus`        |

  ## ProductOffer

  `ProductOffer` URL's cover:

  - `???`

  The following fields are added:

  | Field                 | Taken from |
  | -----                 | ---------- |
  | `product_name`        | ?          |
  | `category_name`       | ?          |
  | `on_sale`             | ?          |
  | `on_sale_percent_off` | ?          |
  | `free_shipping`       | ?          |
  | `minimum_price`       | ?          |
  | `maximum_price`       | ?          |
  """

  import Enum, only: [map: 2]

  def transform(data, assigns) do
    data
    |> update_in(["categories", "category"], fn cats ->
      cats |> map(& map_category(&1, assigns))
    end)
  end

  @doc """
  Transforms a `category` object.
  """
  def map_category(cat, assigns) do
    cat
    |> Map.update("categoryURL", nil, fn url ->
      build_url(url, assigns, category_name: cat["name"])
    end)
  end

  @doc """
  Builds a URL for a given `url`.
  """
  def build_url(url, assigns, extras \\ []) do
    options = %{
      link: url,
      domain: URI.parse(url).host,
      is_mobile: assigns.is_mobile,
      result_keyword: assigns.params["keyword"],
      ip_address: assigns.params["visitorIPAddress"],
      country_code: assigns.country,
      user_agent: assigns.params["visitorUserAgent"],
      request_domain: assigns.params["domain"]
    }

    options = Enum.into(extras, options)

    build_url_string(options, assigns)
  end

  @doc """
  Builds a URL from given `params`.
  """

  def build_url_string(params, assigns) do
    assigns.redirect_base
    <> Base.encode64("?" <> URI.encode_query(params))
  end
end

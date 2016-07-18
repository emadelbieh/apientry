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

      pry> Base.url_decode64!("P2xpbms9aHR0cDovL2dvb2dsZS5jb20maXNfbW9iaWxlPXRydWU=")
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
  - `searchHistory.categorySelection[].categoryURL`

  The following fields are added:

  | Field           | Taken from             |
  | -----           | ----------             |
  | `category_name` | `category.name`        |
  | `event`         | `"CLICK_CATEGORY_URL"` |

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
  | `event`          | `"CLICK_OFFER_URL"`        |

  ## ProductOffer

  `ProductOffer` URL's cover:

  - `categories.category[].items.item[].product`

  The following fields are added:

  | Field                 | Taken from                 |
  | -----                 | ----------                 |
  | `product_name`        | `product.name`             |
  | `category_name`       | `category.name`            |
  | `on_sale`             | `product.onSale`           |
  | `on_sale_percent_off` | `product.onSalePercentOff` |
  | `free_shipping`       | `product.freeShipping`     |
  | `minimum_price`       | `product.minPrice.value`   |
  | `maximum_price`       | `product.maxPrice.value`   |
  | `event`               | `"CLICK_PRODUCT_URL"`      |

  ## Attribute URL

  - `categories.category[].attributes.attribute[].attributeURL

  | Field            | Taken from              |
  | -----            | ----------              |
  | `category_name`  | `category.name`         |
  | `attribute_name` | `attirbute.name`        |
  | `event`          | `"CLICK_ATTRIBUTE_URL"` |

  ## Review URL

  - `categories.category[].items.item[].offer.store.ratingInfo.reviewURL`

  | Field                 | Taken from                 |
  | -----                 | ----------                 |
  | `store`               | `store.name`               |
  | `trusted`             | `store.trusted`            |
  | `authorized_reseller` | `store.authorizedReseller` |
  | `event`               | `"CLICK_REVIEW_URL"`       |

  ## AttributeValue URL

  - `categories.category[].attributes.attribute[].attributeValues.attributeValue[].attributeValueURL`

  The following fields are added:

  | Field                  | Taken from                   |
  | -----                  | ----------                   |
  | `category_name`        | `category.name`              |
  | `attribute_name`       | `attirbute.name`             |
  | `attribute_value_name` | `attirbute_value.name`       |
  | `event`                | `"CLICK_ATTRIBUTEVALUE_URL"` |
  """

  alias Apientry.DomainFilter

  def transform(data, assigns) do
    data
    |> safe_update_in(["categories", "category"], fn cats ->
      cats
      |> Stream.filter(&filter_item(&1, assigns, ["categoryURL"]))
      |> Enum.map(&map_category(&1, assigns))
    end)
    |> safe_update_in(["searchHistory", "categorySelection"], fn cats ->
      cats
      |> Stream.filter(&filter_item(&1, assigns, ["categoryURL"]))
      |> Enum.map(& map_category(&1, assigns))
    end)
  end

  @doc """
  Transforms a `category` object.

  Categories are in `categories.category[]`.
  """
  def map_category(cat, assigns) do
    cat
    |> Map.update("categoryURL", nil, fn url ->
      build_url(url, assigns,
       event: "CLICK_CATEGORY_URL",
       category_name: cat["name"])
    end)
    |> safe_update_in(["attributes", "attribute"], fn attributes ->
      attributes
      |> Stream.filter(&filter_item(&1, assigns, ["attributeURL"]))
      |> Enum.map(&map_attribute(&1, cat, assigns))
    end)
    |> safe_update_in(["items", "item"], fn items ->
      items
      |> Stream.filter(&filter_item(&1, assigns, ["offer", "offerURL"]))
      |> Stream.filter(&filter_item(&1, assigns, ["product", "productOffersURL"]))
      |> Enum.map(&map_item(&1, cat, assigns))
    end)
    |> safe_update_in(["items"], fn items ->
      count = length(items["item"] || [])
      items
      |> Map.put("returnedItemCount", count)
    end)
  end

  @doc """
  Filters out items from the same domain.
  """
  def filter_item(item, %{params: %{"domain" => domain}} = _assigns, access) do
    case get_in(item, access) do
      nil -> true
      url -> ! DomainFilter.matches?(domain, URI.parse(url).host)
    end
  end

  @doc """
  Transforms an `item` object.

  Item objects are in `cat.items.item[]`.
  """
  def map_item(item, cat, assigns) do
    item
    |> Map.update("offer", nil, fn offer ->
      map_offer(offer, cat, assigns)
    end)
    |> Map.update("product", nil, fn product ->
      map_product(product, cat, assigns)
    end)
  end

  @doc """
  Transforms an `offer` object.

  Offers are in `item.offer`.
  """
  def map_offer(offer, _cat, assigns) do
    offer
    |> Map.update("offerURL", nil, fn url ->
      build_url(url, assigns,
       event: "CLICK_OFFER_URL",
       offer_name: offer["name"],
       manufacturer: offer["manufacturer"],
       used: offer["used"],
       price_value: offer["basePrice"]["value"],
       currency: offer["basePrice"]["currency"],
       stock_status: offer["stockStatus"])
    end)
    |> Map.update("store", nil, fn store ->
      map_store(store, assigns)
    end)
  end

  @doc """
  Transforms a `product` object.

  Products are in `item.product`.
  """
  def map_product(product, category, assigns) do
    product
    |> Map.update("productOffersURL", nil, fn url ->
      build_product_url(url, assigns, product, category)
    end)
    |> Map.update("productSpecsURL", nil, fn url ->
      build_product_url(url, assigns, product, category)
    end)
  end

  def build_product_url(url, assigns, product, category) do
    build_url(url, assigns,
     event: "CLICK_PRODUCT_URL",
     product_name: product["name"],
     category_name: category["name"],
     on_sale: product["onSale"],
     on_sale_percent_off: product["onSalePercentOff"],
     free_shipping: product["freeShipping"],
     minimum_price: get_in(product, ["minPrice", "value"]),
     maximum_price: get_in(product, ["maxPrice", "value"]))
  end

  @doc """
  Transforms a `store` object.
  """

  def map_store(store, assigns) do
    store
    |> safe_update_in(["ratingInfo", "reviewURL"], fn url ->
      build_url(url, assigns,
       event: "CLICK_REVIEW_URL",
       store: store["name"],
       trusted: store["trusted"],
       authorized_reseller: store["authorizedReseller"])
    end)
  end

  @doc """
  Transforms an `attribute` object.

  Attributes are in `category.attributes.attribute[]`.
  """
  def map_attribute(attribute, category, assigns) do
    attribute
    |> Map.update("attributeURL", nil, fn url ->
      build_url(url, assigns,
       event: "CLICK_ATTRIBUTE_URL",
       category_name: category["name"],
       attribute_name: attribute["name"])
    end)
    |> safe_update_in(["attributeValues", "attributeValue"], fn items ->
      items
      |> Stream.filter(&filter_item(&1, assigns, ["attributeValueURL"]))
      |> Enum.map(& map_attribute_value(&1, attribute, category, assigns))
    end)
  end

  @doc """
  Maps an `attributeValue` object.

  Found in `attribute.attributeValues.attributeValue[]`.
  """
  def map_attribute_value(attribute_value, attribute, category, assigns) do
    attribute_value
    |> Map.update("attributeValueURL", nil, fn url ->
      build_url(url, assigns,
       event: "CLICK_ATTRIBUTEVALUE_URL",
       category_name: category["name"],
       attribute_name: attribute["name"],
       attribute_value_name: attribute_value["name"])
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
    <> Base.url_encode64("?" <> URI.encode_query(params))
  end

  # Supress nil errors, in case an offer has no items (or whatnot).
  defp safe_update_in(data, keys, fun) do
    try do
      update_in(data, keys, fun)
    rescue
      _ -> data
    end
  end
end

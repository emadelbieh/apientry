defmodule Apientry.CategoryChooser do
  @global_chooser %{
    "us" => %{
      clothing: &clothingUs/1,
      laptops: &laptopsUs/1
    },
    "au" => %{
      clothing: &clothingUs/1,
      laptops: &laptopsUs/1,
    },
    "de" => %{
      laptops: &laptopsUs/1
    },
    "gb" => %{
      clothing: &clothingUs/1
    },
    "fr" => %{
      tvFr: &tvFr/1,
      oven: &ovenFr/1,
      microwave: &microwaveFr/1,
      lingerie: &lingerieFr/1,
      sofa: &sofaFr/1,
      bags: &bagsFr/1,
      shoes: &shoesFr/1,
      laptops: &laptopsUs/1,
      clothing: &clothingFr/1
    }
  }
  
  def initialize(data) do
    chooser = nil
    set_geo(data)
  end

  def set_geo(data) do
    set_global_chooser(geo)
  end

  def get(geo, data) do
    cat_data_from_amazon(data) || cat_data_from_default_chooser(geo, data)
  end

  def cat_data_from_amazon(data) do
    Apientry.AmazonMapper.get_cat_data(data)
  end

  def cat_data_from_default_chooser(geo, data) do
    chooser = @global_chooser[geo]
    Stream.filter(chooser, fn {key, value} ->
      apply(chooser[key], data)
    end)
  end

  def clothingUs do
    str = ""

    title = kw
    pageTitle = pageTitle
    url = siteUrl
    breadCrumbs = breadCrumbs

    title = URI.decode(title)
    str = "#{title} #{pageTitle} #{breadCrumbs}"

    catId = "31515"
    attribute_value = []

    str = str
    |> Apientry.Rerank.tokenize("us")
    |> Enum.join(" ")

    gender = %{
      "women" => "71816_women",
      "men" => "71816_men",
      "boys" => "71816_boys",
      "girls" => "71816_girls"
    };

    rules = ~w[bra hats hat hoodie Fleece Tunic dress shirt shirts t shirt bra bras boxer pants jacket shorts short Panties Sweatshirts Crew Socks Bikini skirts Cardigan Cardigans skirt Pullovers Sweater Vests jeans Jean Coats Swimwear Swimwears Sleepwear Sleepwears Socks Leggings Legging Lingerie Lingeries Underwear Underwears Stretch Fit V Neck]

    strongattributes = %{
      "pants": ["pants"],
      "71827_jackets_vests": ['jackets', "jacket", 'vests'],
      "dresses": ['dresses', 'dress'],
      "71827_sweaters_and_sweatshirts": ['sweaters', 'sweater', 'sweatshirts', 'sweatshirt'],
      "71827_underwear_and_lingerie": ['underwear', 'lingerie'],
      "71827_shorts": ['shorts'],
      "71827_jeans": ['jeans'],
      "71827_coats": ['coats', 'coat'],
      "71827_skirts": ['skirts', 'skirt']
    }

    rules = rules
    |> Enum.map(fn rule ->
      rule = String.downcase(rule)
      rule = "\\b#{rule}\\b"
    end)
    |> Enum.join("|")
    rules = "(#{rules})"

    {:ok, rule_regex} = Regex.compile(rules)

    is_in_cat = str =~ rule_regex

    if is_in_cat do
      gender_rec = Apientry.Helpers.recognize_gender(str)

      if gender_rec && gender[gender_rec] do
        attribute_value = [gender[gender_rec] | attribute_value]
      end

      attrs_ids = Enum.filter(strongattributes, fn {attrId, attributes} ->
        attributes_reg = Enum.join(attributes_reg, "\\b|\\b")
        attributes_reg = "(\\b#{attributes_reg}\\b)"
        {:ok, regex} = Regex.compile(attributes_reg)
        str =~ regex
      end)

      if length(attrs_ids) > 0 do
        attribute_value = [hd(attr_ids) | attribute_value]
      end

      %{
        catId: catId,
        attribute_value: attribute_value
      }
    end

    nil
  end

  def laptopsUs do
  end

  def clothingFr do
  end

  def shoesFr do
  end

  def sofaFr do
  end

  def bagsFr do
  end

  def lingerieFr do
  end

  def microwaveFr do
  end

  def ovenFr do
  end

  def tvFr do
  end
end

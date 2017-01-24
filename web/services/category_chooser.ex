require IEx

defmodule Apientry.CategoryChooser do
  def clothingUs(data) do
    str = ""

    title = data.kw
    pageTitle = data.pageTitle
    url = data.siteUrl
    breadCrumbs = data.breadCrumbs

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
        attributes_reg = Enum.join(attributes, "\\b|\\b")
        attributes_reg = "(\\b#{attributes_reg}\\b)"
        {:ok, regex} = Regex.compile(attributes_reg)
        str =~ regex
      end)

      if length(attrs_ids) > 0 do
        attribute_value = [hd(attrs_ids) | attribute_value]
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

  @global_chooser %{
    "us" => %{
      clothing: &__MODULE__.clothingUs/1,
      laptops: &__MODULE__.laptopsUs/1
    },
    "au" => %{
      clothing: &__MODULE__.clothingUs/1,
      laptops: &__MODULE__.laptopsUs/1,
    },
    "de" => %{
      laptops: &__MODULE__.laptopsUs/1
    },
    "gb" => %{
      clothing: &__MODULE__.clothingUs/1
    },
    "fr" => %{
      tvFr: &__MODULE__.tvFr/1,
      oven: &__MODULE__.ovenFr/1,
      microwave: &__MODULE__.microwaveFr/1,
      lingerie: &__MODULE__.lingerieFr/1,
      sofa: &__MODULE__.sofaFr/1,
      bags: &__MODULE__.bagsFr/1,
      shoes: &__MODULE__.shoesFr/1,
      laptops: &__MODULE__.laptopsUs/1,
      clothing: &__MODULE__.clothingFr/1
    }
  }
  
  def get(data) do
    cat_data_from_amazon(data) || cat_data_from_default_chooser(data)
  end

  def cat_data_from_amazon(data) do
    Apientry.AmazonMapper.get_category_data(data)
  end

  def cat_data_from_default_chooser(data) do
    IO.inspect data
    chooser = @global_chooser[data.geo]
    IO.inspect chooser
    Stream.filter(chooser, fn {key, value} ->
      apply(chooser[key], data)
    end)
    |> Enum.at(0) || %{}
  end
end

defmodule Apientry.ClothingUS do
  @category_id "31515"

  @rules ~w[bra hats hat hoodie Fleece Tunic dress shirt shirts t shirt bra bras boxer pants jacket shorts short Panties Sweatshirts Crew Socks Bikini skirts Cardigan Cardigans skirt Pullovers Sweater Vests jeans Jean Coats Swimwear Swimwears Sleepwear Sleepwears Socks Leggings Legging Lingerie Lingeries Underwear Underwears Stretch Fit V Neck]

  @strong_attributes %{
                             "pants" => ["pants"],
               "71827_jackets_vests" => ["jackets", "jacket", "vests"],
                           "dresses" => ["dresses", "dress"],
    "71827_sweaters_and_sweatshirts" => ["sweaters", "sweater", "sweatshirts", "sweatshirt"],
      "71827_underwear_and_lingerie" => ["underwear", "lingerie"],
                      "71827_shorts" => ["shorts"],
                       "71827_jeans" => ["jeans"],
                       "71827_coats" => ["coats", "coat"],
                      "71827_skirts" => ["skirts", "skirt"]
  }

  def category_id do
    @category_id
  end

  def rules do
    @rules
  end

  def strong_attributes do
    @strong_attributes
  end

  def genders do
    %{
      "women" => "71816_women",
      "men"   => "71816_men",
      "boys"  => "71816_boys",
      "girls" => "71816_girls"
    }
  end
end

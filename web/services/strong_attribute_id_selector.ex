defmodule Apientry.StrongAttributeIDSelector do
  @strong_attribute_selector %{
    "us" => %{
      "96668" => %{
        "women"=> "73636_women",
        "men" => "73636_men"
      },
      "96602" => %{
        "women"=> "women",
        "men" => "23995114_men"
      },
      "92" => %{
        "women"=> "24083917_women",
        "men" => "24083917_men"
      },
      "68185" => %{
        "women"=> "24093937_women",
        "men" => "24093937_men"
      },
      "31515" => %{
        "women"=> "71816_women",
        "men" => "71816_men"
      },
      "276" => %{
        "women"=> "71603_women",
        "men" => "71603_men"
      },
      "22686" => %{
        "women"=> "24088355_women",
        "men" => "24088355_men"
      },
      "1424" => %{ "women"=> "24086907_women",
        "men" => "24086907_men"
      }
    },
    "fr" => %{
      "31515" => %{
        "femme" => "24347227_femmes",
        "homme" => "24347227_hommes"
      },
      "276" => %{
        "femme" => "24347083_femmes",
        "homme" => "24347083_hommes"
      },
      "31600" => %{
        "femme" => "24347083_femmes",
        "homme" => "24347441_hommes"
      },
      "1424" => %{
        "femme" => "24314994_femme",
        "homme" => "24217673_homme"
      },
      "92" => %{
        "femme" => "femme",
        "homme" => "homme"
      },
      "96667" => %{
        "femme" => "24348943_femmes",
        "homme" => "24348943_hommes"
      },
      "96602" => %{
        "femme" => "24315803_femmes",
        "homme" => "24315803_hommes"
      }
    },
    "de" => %{
      "31515" => %{
        "damen" => "24361087_damen",
        "herren" => "24361087_herren"
      },
      "276" => %{
        "damen" => "24364376_damen",
        "herren" => "24364376_herren"
      },

      "96667" => %{
        "damen" => "24365630_damen",
        "herren" => "24365630_herren"
      }
    }
  }

  def get_strong_attr_ids(data) do
    data = data
    |> init()
    |> combine_keywords()
    |> decode_keywords()
    |> normalize_keywords()
    |> Apientry.CategoryChooser.recognize_gender()
    |> add_gender_attribute()

    if Map.has_key?(data, :gender_attribute) do
      %{
        categoryId: data.category_id,
        attributeValue: data.gender_attribute
      }
    else
      %{
        categoryId: data.category_id,
        attributeValue: nil
      }
    end
  end

  defp init(data) do
    %{
              geo: data["geo"]         || "",
            title: data["kw"]          || "",
      category_id: data["category_id"] || "",
       page_title: data["page_title"]  || "",
      breadcrumbs: data["breadcrumbs"] || ""
    }
  end

  defp combine_keywords(data) do
    keywords = "#{data.title} #{data.page_title} #{data.breadcrumbs}"
    Map.put(data, :keywords, keywords)
  end

  defp decode_keywords(data) do
    decoded = URI.decode(data.keywords)
    Map.put(data, :keywords, decoded)
  end

  defp normalize_keywords(data) do
    normalized = Apientry.Rerank.normalize_string(data.keywords)
    Map.put(data, :keywords, normalized)
  end

  defp add_gender_attribute(data) do
    data = if data.gender do
      selectors = @strong_attribute_selector[data.geo][data.category_id]
      gender_attribute = selectors[data.gender]
      Map.put(data, :gender_attribute, gender_attribute)
    else
      data
    end
  end

end

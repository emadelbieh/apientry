defmodule Apientry.AmazonMapper do
  @mapper %{
    "us" => %{
      "electronics, television & video, televisions" => %{
        cat_id: "96252",
        attribute_value: []
      },
      "clothing, shoes & jewelry, women, shoes" => %{
        cat_id: "96602",
        attribute_value: ["women"]
      },
      "clothing, shoes & jewelry, men, shoes" => %{
        cat_id: "96602",
        attribute_value: ["23995114_men"]
      },
      "electronics, headphones" => %{
        cat_id: "418"
      }
    },
    "fr" => %{ "chaussures et sacs, sacs" => %{
        cat_id: "96668",
        attribute_value: []
      },
      "chaussures et sacs, chaussures, chaussures femme" => %{
        cat_id: "96602",
        attribute_value: ["24315803_femmes"]
      }, "chaussures et sacs, chaussures, chaussures homme" => %{
        cat_id: "96602",
        attribute_value: ["24315803_hommes"]
      },
      "montres," => %{
        cat_id: "277"
      },
      "high-tech, tv, vidéo & home cinéma, téléviseurs" => %{
        cat_id: "96252"
      },
      "high-, tech, téléphones portables et accessoires, smartphones et téléphones portables débloqués" => %{
        cat_id: "93767"
      }
    }
  }

  def get_category_data(geo) do
    cond do
      !geo || !@mapper[geo] ->
        nil
      !bread_crumbs || length(breadcrumbs) < 4 ->
        nil
      true ->
        mapper_keys = Map.keys(@mapper["us"])
        mapper_keys = Enum.join("|")
        mapper_keys = "(#{mapper_keys})"
        {:ok, regex} = Regex.compile(mapper_keys)
        if bread_crumbs =~ regex do
          key = Regex.run(regex, bread_crumbs)
          @mapper[key]
        else
          nil
        end
    end
  end
end

require IEx

defmodule Apientry.CategoryChooser do
  def init(data) do
    %{
                   geo: data["geo"]         || "",
                 title: data["kw"]          || "",
            page_title: data["page_title"]  || "",
           breadcrumbs: data["breadcrumbs"] || "",
      attribute_values: [],
    } end

  def get_category_data(data) do
    data = data
    |> decode_title()
    |> combine_keywords()
    |> tokenize_keywords()
    |> combine_tokens()
    |> match_with_rules()
    |> recognize_gender()
    |> add_gender_attribute()
    |> add_strong_attributes()

    if data.rules_match do
      %{
        category_id: get_category_id(data),
        attribute_value: data.attribute_values
      }
    else
      nil
    end
  end
  
  defp get_category_id(data) do
    Apientry.ClothingUS.category_id
  end

  defp get_rules(data) do
    Apientry.ClothingUS.rules
  end

  defp get_genders(data) do
    Apientry.ClothingUS.genders
  end

  defp get_strong_attributes(data) do
    Apientry.ClothingUS.strong_attributes
  end

  defp decode_title(data) do
    title = URI.decode(data.title)
    Map.put(data, :title, title)
  end

  defp combine_keywords(data) do
    keywords = "#{data.title} #{data.page_title} #{data.breadcrumbs}"
    Map.put(data, :keywords, keywords)
  end

  defp tokenize_keywords(data) do
    tokens = data.keywords |> Apientry.Rerank.tokenize(data.geo)
    Map.put(data, :tokens, tokens)
  end

  defp combine_tokens(data) do
    keywords = data.tokens |> Enum.join(" ")
    Map.put(data, :keywords, keywords)
  end

  defp match_with_rules(data) do
    rules = get_rules(data)
            |> Enum.map(fn rule ->
              rule = String.downcase(rule)
              rule = "\\b#{rule}\\b"
            end)
    |> Enum.join("|")
    rules = "(#{rules})"
    {:ok, rule_regex} = Regex.compile(rules)

    has_match = data.keywords =~ rule_regex

    Map.put(data, :rules_match, has_match)
  end

  defp add_gender_attribute(data) do
    data = if data.gender do
      genders = get_genders(data)

      if genders[data.gender] do
        Map.put(data, :attribute_values, [genders[data.gender] | data.attribute_values])
      else
        data
      end
    else
      data
    end
  end

  defp add_strong_attributes(data) do
    if data.rules_match do
      attrs_ids = data
      |> get_strong_attributes()
      |> Enum.filter(fn {attrId, attributes} ->
        attributes_reg = Enum.join(attributes, "\\b|\\b")
        attributes_reg = "(\\b#{attributes_reg}\\b)"
        {:ok, regex} = Regex.compile(attributes_reg)
        data.keywords =~ regex
      end)

      if length(attrs_ids) > 0 do
        attribute_values = [hd(attrs_ids) | data.attribute_values]
        Map.put(data, :attribute_values, attribute_values)
      else
        data
      end
    else
      data
    end
  end

  def recognize_gender(data) do
    str = data.keywords

    gender = cond do
      str =~ ~r/(\herren\b)/ ->
        "herren"
      str =~ ~r/(\bdamen\b)/ ->
        "damen"
      str =~ ~r/(\bfemme\b)/ ->
        "femme"
      str =~ ~r/(\bhomme\b)/ ->
        "homme"
      str =~ ~r/(\bwomen\b|\bwoman\b|\bwomens\b)/ ->
        "women"
      str =~ ~r/(\bmen\b|\bman\b|\bmens\b|\bmans\b)/ ->
        "men"
      true ->
        nil
    end

    Map.put(data, :gender, gender)
  end
end

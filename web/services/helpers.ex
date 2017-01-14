defmodule Apientry.Helpers do
  def load_ebay_data do
    File.stream!("web/services/ebaydataus.csv")
    |> CSV.decode()
    |> Stream.map(fn row ->
      downcased = Stream.map(row, &String.downcase/1)

      [:cat_id, :cat_name, :attribute_name, :attribute_value_name, :attribute_value_id]
      |> Stream.zip(downcased)
      |> Enum.into(%{})
    end)
    # normalize data here, see helpers.js 142-147
    |> Stream.reject(fn data ->
      #data.attribute_name in ["store", "fourchette de prix", "magasin", "online shop"]
      data.attribute_name == "store"
    end)
  end

  def create_attr_tree(ebay_data) do
    ebay_data
    |> Enum.reduce(%{}, fn data, acc ->
      attribute_value_name = data.attribute_value_name
      attribute_value_name = String.replace(attribute_value_name, ~r/ *\([^)]*\) */, "")
      attribute_value_name = String.replace(attribute_value_name, ~r/[|\\{}()[\]^$+*?.]/, "\\$&")
      attribute_value_name = "\\b#{attribute_value_name}\\b"

      if acc[data.cat_id] do
        list = acc[data.cat_id]
        list = [attribute_value_name | list]
        Map.put(acc, data.cat_id, list)
      else
        Map.put(acc, data.cat_id, [attribute_value_name])
      end
    end)
  end

  def regex_from_attr_tree(attr_tree) do
    Enum.reduce(attr_tree, %{}, fn {cat_id, attr_name_list}, acc ->
      regex = Enum.join(attr_name_list, "|")
      regex = "(#{regex})"
      Map.put(acc, cat_id, regex)
    end)
  end

  def get_regex_string(cat_id) do
    tree = load_ebay_data
    |> create_attr_tree
    |> regex_from_attr_tree

    result = tree[cat_id]

    IO.puts "********** regex string **********"
    IO.inspect(result)
    IO.puts "********** regex string **********"

    result
  end
end

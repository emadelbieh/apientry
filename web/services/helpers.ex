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
    |> Enum.reject(fn data ->
        data.attribute_name in ["store", "fourchette de prix", "magasin", "online shop"]
    end)
  end
end

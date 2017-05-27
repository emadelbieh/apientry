defmodule Apientry.TitleCleaner do
  @stopwords [
    "avec offres spéciales",
    "peter hahn",
    "fiyatı",
    "undefined",
    "offres spéciales",
    "la fiche produit"
  ]

  def clean(title) do
    title
    |> String.downcase()
    |> ellipses_to_spaces()
    |> dashes_to_spaces()
    |> slashes_to_spaces()
    |> remove_stop_words()
    |> remove_copyright_characters()
    |> multiple_to_single_spaces()
  end

  defp ellipses_to_spaces(string) do
    string
    |> String.replace("...", " ")
  end

  defp dashes_to_spaces(string) do
    string
    |> String.replace("-", " ")
  end

  defp slashes_to_spaces(string) do
    string
    |> String.replace("/", " ")
  end

  defp multiple_to_single_spaces(string) do
    string
    |> String.replace(~r/ +(?= )/, "")
  end

  defp remove_copyright_characters(string) do
    string
    |> String.replace(~r/©|®|™/, "")
  end

  def remove_stop_words(string) do
    Enum.reduce(@stopwords, string, fn stopword, acc ->
      String.replace(acc, stopword, "")
    end)
  end
end

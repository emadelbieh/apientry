defmodule Apientry.Rerank.Stemmer do
  @keywords_dont_stemm ~w(homme hommes femme femmes herren)

  @supported_geos ~w(us au gb de fr)

  @stemmers %{
    "us" => &Stemex.english/1,
    "au" => &Stemex.english/1,
    "gb" => &Stemex.english/1,
    "de" => &Stemex.german/1,
    "fr" => &Stemex.french/1,
  }

  def stem(string, "fr") when string in @keywords_dont_stemm do
    string
  end

  def stem(string, geo) when geo in @supported_geos do
    @stemmers[geo].(string)
  end

  def stem(string, _) do
    string
  end
end

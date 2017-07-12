defmodule Apientry.Rerank.StemmerTest do
  use ExUnit.Case

  alias Apientry.Rerank.Stemmer

  test "#stem don't stem keywords" do
    assert Stemmer.stem("homme", "fr") == "homme"
    assert Stemmer.stem("hommes", "fr") == "hommes"
    assert Stemmer.stem("femme", "fr") == "femme"
    assert Stemmer.stem("femmes", "fr") == "femmes"
    assert Stemmer.stem("herren", "fr") == "herren"
  end

  test "#stem don't stem words for unsupported geos" do
    assert Stemmer.stem("consigned", "ph") == "consigned"
    assert Stemmer.stem("consigning", "ph") == "consigning"
    assert Stemmer.stem("consignment", "ph") == "consignment"
  end

  test "#stem stems English words for geo=us,gb,au" do
    assert Stemmer.stem("consigned", "us") == "consign"
    assert Stemmer.stem("consigning", "gb") == "consign"
    assert Stemmer.stem("consignment", "au") == "consign"
  end

  test "#stem stems German words for geo=de" do
    assert Stemmer.stem("aufeinanderfolge", "de") == "aufeinanderfolg"
    assert Stemmer.stem("aufeinanderfolgen", "de") == "aufeinanderfolg"
    assert Stemmer.stem("aufeinanderfolgende", "de") == "aufeinanderfolg"
  end

  test "#stem stems French words for geo=fr" do
    assert Stemmer.stem("continuel", "fr") == "continuel"
    assert Stemmer.stem("continuelle", "fr") == "continuel"
    assert Stemmer.stem("continuellement", "fr") == "continuel"
  end
end

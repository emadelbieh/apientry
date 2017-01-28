defmodule Apientry.ClothingFR do
  @category_id "31515"

  @rules ~w[Chaussette, Cardigan, Cardigans, Tunique, Tuniques, Sweatshirts, chaussettes, Vêtements, Vêtement, T-Shirts, T-Shirt, T Shirts, T Shirt, Chemises, Manteaux, Pyjama, Pyjamas, blouse, Denim, Legging, Manteau, veste, vestes, Maillot de bain, jupe, pull col, pantalon, pantalons, Robe, Robes, jupes]

  @strong_attributes %{
           "24347218_chaussettes" => ['chaussette', 'chaussettes'],
                     "chemisiers" => ['chemisier', 'Chemise', 'Chemises'],
                       "tuniques" => ['tunique'],
    "24347218_manteaux_et_vestes" => ['manteaux','MANTEAU'],
           "24347217_sweatshirts" => ['sweatshirt'],
                 "24347218_jupes" => ['jupes'],
             "24347218_pantalons" => ['pantalons'],
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
        "enfants" => "24347227_enfants",
        "homme"   => "24347227_hommes",
        "femme"   => "24347227_femmes"
    }
  end
end

defmodule Apientry.MerchantView do
  use Apientry.Web, :view

  def render("index.json", %{merchants: merchants}) do
    %{data: render_many(merchants, Apientry.MerchantView, "merchant.json")}
  end

  def render("show.json", %{merchant: merchant}) do
    %{data: render_one(merchant, Apientry.MerchantView, "merchant.json")}
  end

  def render("merchant.json", %{merchant: merchant}) do
    %{id: merchant.id,
      merchant: merchant.merchant,
      slug: merchant.slug,
      website: merchant.website,
      domain: merchant.domain,
      url: merchant.url,
      network: merchant.network,
      country: merchant.country,
      logo: merchant.logo}
  end
end

defmodule Apientry.Coupon do
  use Apientry.Web, :model

  alias Apientry.EbayJsonTransformer

  schema "coupons" do
    field :merchant, :string
    field :merchantid, :string
    field :offer, :string
    field :restriction, :string
    field :url, :string
    field :code, :string
    field :startdate, :string
    field :enddate, :string
    field :category, :string
    field :dealtype, :string
    field :holiday, :string
    field :network, :string
    field :rating, :string
    field :country, :string
    field :logo, :string
    field :website, :string
    field :domain, :string
    field :lastmodified, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :merchant, :merchantid, :offer, :restriction, :url, :code, :startdate, :enddate, :category, :dealtype, :holiday, :network, :rating, :country, :logo, :website, :domain, :lastmodified])
    |> validate_required([:id, :merchant, :merchantid, :offer, :url, :code, :startdate, :enddate, :category, :dealtype, :holiday, :network, :rating, :country, :logo, :website, :domain, :lastmodified])
  end

  def by_domain_name(conn, domain) do
    coupons = Apientry.Repo.all(from c in Apientry.Coupon, where: c.domain == ^domain)
    track(conn, coupons)
  end

  def track(conn, coupons) do
    Enum.map(coupons, fn coupon ->
      Map.put(coupon, :url, build_url(conn, coupon))
    end)
  end

  def build_url(conn, coupon) do
    EbayJsonTransformer.build_url(coupon.url, %{
        is_mobile: conn.assigns[:is_mobile],
        params: %{
          "keyword" => conn.params["keyword"],
          "visitorIPAddress" => conn.params["visitorIPAddress"],
          "visitorUserAgent" => conn.params["visitorUserAgent"],
          "domain" => conn.params["domain"]
        },
        country: conn.assigns[:country],
        redirect_base: conn.assigns[:redirect_base]
      },
      event: "CLICK_COUPON_URL",
      offer_name: coupon.offer,
      dealtype: coupon.dealtype,
      merchant: coupon.merchant,
      network: coupon.network,
      category: coupon.category,
      code: coupon.code,
      rating: coupon.rating)
  end

  def to_map(coupons) when is_list(coupons) do
    Enum.map(coupons, fn coupon ->
      to_map(coupon)
    end)
  end

  def to_map(coupon) do
    %{
          merchant: coupon.merchant,
        merchantid: coupon.merchantid,
             offer: coupon.offer,
       restriction: coupon.restriction,
               url: coupon.url,
              code: coupon.code,
         startdate: coupon.startdate,
           enddate: coupon.enddate,
          category: coupon.category,
          dealtype: coupon.dealtype,
           holiday: coupon.holiday,
           network: coupon.network,
            rating: coupon.rating,
           country: coupon.country,
              logo: coupon.logo,
           website: coupon.website,
            domain: coupon.domain,
      lastmodified: coupon.lastmodified
  }
  end
end

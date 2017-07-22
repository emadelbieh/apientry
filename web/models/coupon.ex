defmodule Apientry.Coupon do
  use Apientry.Web, :model

  alias Apientry.EbayJsonTransformer
  alias Apientry.Repo
  alias Apientry.PublisherSubId
  alias Apientry.Publisher
  alias Apientry.CouponHelper
  
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
    |> validate_required([:id, :merchant, :merchantid, :url, :code, :startdate, :enddate, :category, :dealtype, :holiday, :network, :rating, :country, :logo, :website, :domain, :lastmodified])
  end

  def with_blacklists(conn, params) do
    publisher_sub_id = DbCache.lookup(:publisher_sub_id, :sub_id, params["subid"])

    bldomains = DbCache.lookup_all(:blacklist, :subid_and_type, {publisher_sub_id.id, "domain"})
      |> Enum.map(&(&1.value))

    blnetworks = DbCache.lookup_all(:blacklist, :subid_and_type, {publisher_sub_id.id, "network"})
      |> Enum.map(&(&1.value))
    blcountries = DbCache.lookup_all(:blacklist, :subid_and_type, {publisher_sub_id.id, "country"})
      |> Enum.map(&(&1.value))

    from c in CouponHelper.base_model(), where: not c.domain in ^bldomains and not c.network in ^blnetworks and not c.country in ^blcountries
  end

  def by_params(conn) do
    params = conn.params

    coupons = with_blacklists(conn, params)
    |> by_key(params)
    |> by_domain(params)
    |> by_network(params)
    |> by_category(params)
    |> by_dealtype(params)
    |> by_holiday(params)
    |> by_country(conn)
    |> Apientry.Repo.all

    track(conn, coupons)
  end

  def by_country(query, conn) do
    country = conn.params["country"] || conn.assigns[:country]

    if country do
      from c in query, where: ilike(c.country, ^country)
    else
      query
    end
  end

  def by_key(query, params) do
    if params["key"] do
      term = params["key"]
      term = String.replace(term, "%", "\\%")
      terms = String.split(term)

      Enum.reduce(terms, query, fn term, query ->
        from c in query, where: ilike(c.offer, ^"%#{term}%")
      end)
    else
      query
    end
  end

  def by_domain(query, params) do
    if params["domain"] do
      from c in query, where: c.domain == ^params["domain"]
    else
      query
    end
  end

  def by_network(query, params) do
    if params["network"] do
      from c in query, where: c.network == ^params["network"]
    else
      query
    end
  end

  def by_category(query, params) do
    if params["category"] do
      from c in query, where: c.category == ^params["category"]
    else
      query
    end
  end

  def by_dealtype(query, params) do
    if params["dealtype"] do
      from c in query, where: c.dealtype == ^params["dealtype"]
    else
      query
    end
  end

  def by_holiday(query, params) do
    if params["holiday"] do
      from c in query, where: c.holiday == ^params["holiday"]
    else
      query
    end
  end

  def track(conn, coupons) do
    Enum.map(coupons, fn coupon ->
      Map.put(coupon, :url, build_url(conn, coupon))
    end)
  end

  def get_publisher_from_sub_id(sub_id) do
    {:ok, publisher_sub_id} = Repo.get(PublisherSubId, sub_id)
    {:ok, publisher} = Repo.get(Publisher, publisher_sub_id.publisher_id)
  end

  def build_url(conn, coupon) do
    publisher_sub_id = Repo.one(from p in PublisherSubId, where: p.sub_id == ^conn.params["subid"])
    publisher = Repo.get(Publisher, publisher_sub_id.publisher_id)

    new_url = "#{coupon.url}&sid=#{publisher_sub_id.sub_id}"

    EbayJsonTransformer.build_url(new_url, %{
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
      event: "click",
      sub_event: "CLICK_COUPON_URL",
      offer_name: coupon.offer,
      dealtype: coupon.dealtype,
      merchant: coupon.merchant,
      network: coupon.network,
      category: coupon.category,
      code: coupon.code,
      rating: coupon.rating,
      publisher: publisher.name,
      subid: publisher_sub_id.sub_id)
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

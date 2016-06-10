defmodule MockEbay do
  @defmodule """
  For mocking eBay requests.

      using MockEbay

      mock_ok do
        HTTPoison.get("http://sandbox.api...")
      end
  """
  alias HTTPoison.Response

  defmacro __using__(_) do
    quote do
      require Mock
    end
  end

  @doc """
  Mock eBay successful requests
  """
  defmacro mock_ok(do: block) do
    quote do
      Mock.with_mock HTTPoison, [get: &MockEbay.http_get/1] do
        unquote(block)
      end
    end
  end

  @doc """
  Mock requests when eBay is down
  """
  defmacro mock_fail(do: block) do
    quote do
      Mock.with_mock HTTPoison, [get: &MockEbay.http_get_fail/1] do
        unquote(block)
      end
    end
  end

  @doc "Mock HTTPoison.get"
  def http_get("http://sandbox.api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?apiKey=78b0db8a-0ee1-4939-a2f9-d3cd95ec0fcc&showOffersOnly=true&trackingId=7000610&visitorIPAddress=&visitorUserAgent=&keyword=nikon") do
    http_get_ok
  end

  @doc "Mock with extra parameter"
  def http_get("http://sandbox.api.ebaycommercenetwork.com/publisher/3.0/json/GeneralSearch?apiKey=78b0db8a-0ee1-4939-a2f9-d3cd95ec0fcc&showOffersOnly=true&trackingId=7000610&visitorIPAddress=&visitorUserAgent=&keyword=nikon&xxx=111") do
    http_get_ok
  end

  def http_get(url) do
    raise "Request not allowed: " <> url
  end

  def http_get_ok do
    res = %Response{
      status_code: 200,
      body: ~s[<GeneralSearchResponse xmlns="urn:types.partner.api.shopping.com"/>],
      headers: [{"Content-Type", "text/xml"}]
    }

    { :ok, res }
  end

  def http_get_fail(_url) do
    { :error, %HTTPoison.Error{id: nil, reason: :nxdomain} }
  end
end

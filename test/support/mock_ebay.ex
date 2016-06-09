defmodule MockEbay do
  @doc """
  Mock eBay successful requests
  """
  defmacro mock_ok(do: block) do
    quote do
      require Mock
      require HTTPoison

      mock_response = %HTTPoison.Response{
        status_code: 200,
        body: ~s[<GeneralSearchResponse xmlns="urn:types.partner.api.shopping.com"/>],
        headers: [{"Content-Type", "text/xml"}]
      }

      mock_get = fn (_url) -> {:ok, mock_response} end

      Mock.with_mock HTTPoison, [get: mock_get] do
        unquote(block)
      end
    end
  end

  defmacro mock_fail(do: block) do
    quote do
      require Mock
      require HTTPoison

      mock_error = %HTTPoison.Error{id: nil, reason: :nxdomain}
      mock_get = fn (_url) -> {:error, mock_error} end

      Mock.with_mock HTTPoison, [get: mock_get] do
        unquote(block)
      end
    end
  end
end

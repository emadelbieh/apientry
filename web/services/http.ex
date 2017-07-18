defmodule Apientry.HTTP do

  for method <- [:get, :post, :put, :patch, :delete] do
    def unquote(method)(url, data \\ [], headers \\ [], opts \\ []) do
      opts = Keyword.merge(opts, [timeout: timeout(), recv_timeout: timeout()])
      apply(HTTPoison, :request, [unquote(method), url, data, headers, opts])
    end
  end

  def timeout() do
    Application.get_env(:apientry, :http_timeout) || 50000
  end
end

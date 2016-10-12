defmodule Apientry.DomainFilter do
  @moduledoc """
  Domain filter used by `Apientry.EbayJsonTransformer`.

      iex> Apientry.DomainFilter.matches?("ebay.com", "ebay.com")
      true

      iex> Apientry.DomainFilter.matches?("ebay.com", "amazon.com")
      false

  There's a special case with some domains; `"ebay.com"` is one of them.

      iex> Apientry.DomainFilter.matches?("ebay.com", "www.shopping.com")
      true

  Subdomains are handled.

      iex> Apientry.DomainFilter.matches?("ebay.com", "sandbox.ebay.com")
      true

      iex> Apientry.DomainFilter.matches?("ebay.com", "notebay.com")
      false
  """

  @doc """
  Checks if the given `domain` matches `host`, taking aliases and subdomains
  into effect.
  """
  def matches?("ebay.com", host) do
    domain_match?("ebay.com", host) ||
    domain_match?("shopping.com", host)
  end

  def matches?("shopping.com", host) do
    domain_match?("ebay.com", host) ||
    domain_match?("shopping.com", host)
  end

  def matches?(_domain, _host) do
    # Don't handle anything that's not ebay.com or shopping.com.
    # https://github.com/blackswan-ventures/apientry/issues/96
    false
  end

  defp domain_match?(domain, host) when domain == host, do: true

  defp domain_match?(domain, host) do
    offset = String.length(host) - String.length(domain) - 1
    String.slice(host, offset..-1) == "." <> domain
  end
end

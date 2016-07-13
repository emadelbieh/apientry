defmodule Apientry.DomainFilter do
  @moduledoc """
  Domain filter used by [Apientry.EbayJsonTransformer].

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
  """

  @doc """
  Checks if the given `domain` matches `host`, taking aliases and subdomains
  into effect.
  """
  def matches?("ebay.com", host) do
    domain_match?("ebay.com", host) ||
    domain_match?("shopping.com", host)
  end

  def matches?(domain, host) do
    domain_match?(domain, host)
  end

  defp domain_match?(domain, host) when domain == host, do: true

  defp domain_match?(domain, host) do
    offset = String.length(host) - String.length(domain)
    String.slice(host, offset..-1) == domain
  end
end

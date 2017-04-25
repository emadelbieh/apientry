defmodule Apientry.CouponSearchView do
  use Apientry.Web, :view

  def render("error.json", %{data: json_data}) do
    json_data
  end
end

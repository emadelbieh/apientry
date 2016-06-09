defmodule Apientry.SearchView do
  use Apientry.Web, :view

  def render("index.json", %{ json: json_data }) do
    json_data
  end
end

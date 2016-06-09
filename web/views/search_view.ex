defmodule Apientry.SearchView do
  use Apientry.Web, :view

  def render("index.xml", %{ data: xml }) do
    xml
  end

  def render("index.json", %{ data: json_data }) do
    json_data
  end

  def render("error.json", %{ data: json_data }) do
    json_data
  end
end

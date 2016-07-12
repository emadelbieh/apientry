defmodule Apientry.SearchView do
  use Apientry.Web, :view

  def render("index.xml", %{data: xml_string}) do
    xml_string
  end

  def render("index.json", %{data: json_data}) do
    json_data
  end

  def render("error.json", %{data: json_data}) do
    json_data
  end
end

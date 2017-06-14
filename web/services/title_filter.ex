defmodule Apientry.TitleFilter do
  alias Apientry.TitleAgent

  def remove_sizes(body) do
    categories = Enum.map(get_categories(body), fn category ->
      items = Enum.map(get_items(category), fn item ->
        name = String.replace(get_name(item), ~r/size:\s*\d+\.*\d*,\s*/i, "")

        if item["offer"] do
          update_in(item["offer"]["name"], fn _ -> name end)
        else
          update_in(item["product"]["name"], fn _ -> name end)
        end
      end)

      update_in(category["items"]["item"], fn _ -> items end)
    end)

    update_in(body["categories"]["category"], fn _ -> categories end)
  end

  def filter_duplicate_title(body) do
    {ok, titles} = TitleAgent.start_link

    categories = Enum.map(get_categories(body), fn category ->
      items = Enum.filter(get_items(category), &(TitleAgent.unique?(titles, get_name(&1))))
      update_in(category["items"]["item"], fn _ -> items end)
    end)

    body = update_in(body["categories"]["category"], fn _ -> categories end)


    TitleAgent.stop(titles)

    body
  end

  ## private functions

  defp get_categories(body) do
    body["categories"]["category"]
  end

  defp get_items(category) do
    category["items"]["item"]
  end

  defp get_name(item) do
    (item["offer"] || item["product"])["name"]
  end
end

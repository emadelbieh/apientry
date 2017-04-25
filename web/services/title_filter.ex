defmodule Apientry.TitleFilter do

  alias Apientry.TitleAgent

  def filter_duplicate(body) do
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

defmodule Apientry.TitleFilter do
  @moduledoc """
  Provides function for filtering duplicate titles
  """

  @doc """
  Filters out duplicate titles
  """
  def filter_duplicate(body) do
    {ok, titles} = start_link

    categories = Enum.map(body["categories"]["category"], fn category ->
      items = Enum.filter(category["items"]["item"], fn item ->
        product = item["offer"] || item["product"]
        unique?(titles, product["name"])
      end)
      update_in(category["items"]["item"], fn _ -> items end)
    end)

    body = update_in(body["categories"]["category"], fn _ -> categories end)

    stop(titles)

    body
  end

  # Agent code: for storing state

  defp start_link do
    {:ok, agent} = Agent.start_link fn -> %{} end
  end

  defp get(agent, title) do
    Agent.get(agent, fn map -> map[title] end)
  end

  defp put(agent, title) do
    Agent.update(agent, fn map -> Map.put(map, title, true) end)
  end

  def unique?(agent, title) do
    case get(agent, title) do
      nil -> 
        true
      _ ->
        put(agent, title)
        false
    end
  end

  def stop(agent) do
    Agent.stop(agent)
  end
end

defmodule Apientry.TitleAgent do
  def start_link do
    {:ok, agent} = Agent.start_link fn -> %{} end
  end

  def unique?(agent, title) do
    case retrieve(agent, title) do
      nil -> 
        store(agent, title)
        true
      _ ->
        false
    end
  end

  def stop(agent) do
    Agent.stop(agent)
  end

  ## utility functions

  defp retrieve(agent, title) do
    Agent.get(agent, fn map -> map[title] end)
  end

  defp store(agent, title) do
    Agent.update(agent, fn map -> Map.put(map, title, true) end)
  end
end

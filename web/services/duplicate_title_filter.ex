defmodule Apientry.DuplicateTitleFilter do
  @moduledoc """
  Provides function for filtering duplicate titles
  """
  def new do
    {:ok, agent} = Agent.start_link fn -> %{} end
    agent
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

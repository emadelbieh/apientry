defmodule Apientry.TitleAgentTest do
  use ExUnit.Case, async: true

  alias Apientry.TitleAgent

  setup do
    {:ok, agent} = TitleAgent.start_link
    {:ok, agent: agent}
  end

  test "unique? returns true for values checked the first time", %{agent: agent} do
    assert TitleAgent.unique?(agent, "Nike Revolution 3 Men's shoes")
  end

  test "unique? returns false for values checked the first time", %{agent: agent} do
    TitleAgent.unique?(agent, "Nike Revolution 3 Men's shoes")
    refute TitleAgent.unique?(agent, "Nike Revolution 3 Men's shoes")
  end
end

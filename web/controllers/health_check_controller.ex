defmodule Apientry.HealthCheckController do
  @moduledoc """
  Health check used by ELB.
  """

  use Apientry.Web, :controller

  def index(conn, _params) do
    conn |> text("")
  end
end

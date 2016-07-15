defmodule Apientry.LoaderVerificationController do
  @moduledoc """
  Verification for loader.io.
  """

  use Apientry.Web, :controller

  def show_b86e3ad1(conn, _params) do
    conn |> text("loaderio-b86e3ad1127445bea97f60fc77392f9c")
  end
end

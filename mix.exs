defmodule Apientry.Mixfile do
  use Mix.Project

  def project do
    [app: :apientry,
     version: git_version,
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Apientry, []},
     applications: [
       :phoenix, :phoenix_html, :cowboy, :logger, :gettext,
       :phoenix_ecto, :postgrex, :httpoison, :geolix,
       :phoenix_slime, :cors_plug, :phoenix_pubsub
     ]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_pubsub, "~> 1.0"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:httpoison, "~> 0.8.3"},
     {:cors_plug, "~> 1.1"},
     {:geolix, "~> 0.10"},
     {:phoenix_slime, github: "slime-lang/phoenix_slime"},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:mock, "~> 0.1.1", only: :test},
     {:exrm, "~> 1.0.5"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  def git_version do
    case System.cmd("git", ["describe", "--tags"]) do
      {result, 0} ->
        String.slice(result, 1..-2) # "v0.0.1\n" -> "0.0.1"
      _ ->
        "0.0.0"
    end
  end
end

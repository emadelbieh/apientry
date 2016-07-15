# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :apientry,
  ecto_repos: [Apientry.Repo]

# Configures the endpoint
config :apientry, Apientry.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "T3Z/e4ybH0x4y/ueJYTGKwQg+pDo79Yh6/OV0nAIoHNcTMWKx03zG4dJLb8ofX4S",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Apientry.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :apientry, :basic_auth, [
  realm: "Admin area",
  username: System.get_env("AUTH_USERNAME") || "admin",
  password: System.get_env("AUTH_PASSWORD") || "1234"
]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

config :geolix,
  databases: [
    {:country, File.cwd! <> "/vendor/mmdb/GeoLite2-Country.mmdb"}
  ]

# Don't auto-update; it's only useful in production
config :apientry, :db_cache, interval: nil

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

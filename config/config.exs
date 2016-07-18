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

config :apientry, :amplitude,
  url: "https://api.amplitude.com/httpapi",
  app_id: "151574",
  api_key: "13368ee3449b1b5bffa9b7253b232e9e",
  secret_key: "a978ce4186ee60c202079ef56274222e"

config :apientry, :ebay_search_domain,
  "http://api.ebaycommercenetwork.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

if File.exists?(File.cwd! <> "/config/#{Mix.env}.override.exs") do
  import_config "#{Mix.env}.override.exs"
else
  import_config "#{Mix.env}.exs"
end

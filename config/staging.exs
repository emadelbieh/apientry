use Mix.Config

config :apientry, Apientry.Endpoint,
  http: [port: 3000],
  url: [
    host: System.get_env("SITE_HOST") || "sandbox.apientry.com",
    port: Integer.parse(System.get_env("SITE_PORT") || "80") |> elem(0)
  ],
  cache_static_manifest: "priv/static/manifest.json",
  root: ".",
  server: true

# Do not print debug messages in production
config :logger, level: :info

config :apientry, Apientry.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :apientry, Apientry.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "postgres://apientrystaging:CzEQyTE2Fb7Qe3DGAN@apientry-staging-rds.c1snflmeflqw.us-east-1.rds.amazonaws.com:5432/apientry_staging",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :apientry, :db_cache, interval: 30_000

config :apientry, :events,
  url: "https://events.apientry.com"

config :apientry, :ebay_search_domain,
  "http://sandbox.api.ebaycommercenetwork.com"

config :rollbax,
  access_token: "fcbe67e9abd04a69b3581fd26062c928",
  environment: "sandbox"

config :apientry, :rollbar_enabled, true

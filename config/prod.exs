use Mix.Config

config :apientry, Apientry.Endpoint,
  http: [port: {:system, "PORT"}],
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
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

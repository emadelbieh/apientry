# This overrides `prod.secret.exs` in edeliver AWS deployments.
use Mix.Config

config :apientry, Apientry.Endpoint,
  http: [port: 3000],
  url: [
    host: "apientry.com",
    port: 80
  ],
  cache_static_manifest: "priv/static/manifest.json",
  root: ".",
  server: true

# Do not print debug messages in production
config :logger, level: :info

config :apientry, Apientry.Endpoint,
  secret_key_base: "mmqcFIqKIVtMAVBn1c0u3YO+m6pzRAloZYNNkUQFJr8TxrRrm/rK0v+LCyDPQ4nI"

# Configure your database
config :apientry, Apientry.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "postgres://apientry:fxuJbaisGapsBacroarh@apientry-production.c1snflmeflqw.us-east-1.rds.amazonaws.com:5432/apientry_production",
  pool_size: 10,
  ssl: true

# Load remotely in AWS, because the local .mmdb file is not available when
# building an exrm release.
config :geolix,
  databases: [
    {:country, "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz"}
  ]

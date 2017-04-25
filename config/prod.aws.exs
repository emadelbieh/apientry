# This overrides `prod.secret.exs` in edeliver AWS deployments.
use Mix.Config

config :apientry, Apientry.Endpoint,
  http: [port: 3000],
  url: [
    host: "api.apientry.com",
    port: 80
  ],
  cache_static_manifest: "priv/static/manifest.json",
  root: ".",
  server: true

config :logger, backends: [Rollbax.Logger]
config :logger, Rollbax.Logger, level: :error

# Do not print debug messages in production
config :logger, level: :error

config :apientry, Apientry.Endpoint,
  secret_key_base: "mmqcFIqKIVtMAVBn1c0u3YO+m6pzRAloZYNNkUQFJr8TxrRrm/rK0v+LCyDPQ4nI"

# Configure your database
config :apientry, Apientry.Repo,
  adapter: Ecto.Adapters.Postgres,
  #url: "postgres://apientry:fxuJbaisGapsBacroarh@apientry-production.c1snflmeflqw.us-east-1.rds.amazonaws.com:5432/apientry_production",
  url: "postgres://apientry:fxuJbaisGapsBacroarh@autoscale-apientry-rds.c1snflmeflqw.us-east-1.rds.amazonaws.com:5432/apientry_production",
  pool_size: 10,
  ssl: true

config :quantum, :apientry,
  cron: [
      "* */6 * * *":  {"Apientry.DownloadMerchantWorker", :perform},
      "9 */6 * * *":  {"Apientry.DownloadCouponWorker", :perform}
  ]

# Load remotely in AWS, because the local .mmdb file is not available when
# building an exrm release.
config :geolix,
  databases: [
    {:country, "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz"}
  ]

config :apientry, :db_cache, interval: 30_000

config :apientry, :events,
  url: "https://events.apientry.com"

config :apientry, :ebay_search_domain,
  "http://api.ebaycommercenetwork.com"

config :rollbax,
  access_token: "fcbe67e9abd04a69b3581fd26062c928",
  environment: "production"

config :apientry, :rollbar_enabled, true

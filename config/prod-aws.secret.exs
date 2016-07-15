# This overrides `prod.secret.exs` in edeliver AWS deployments.
use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :apientry, Apientry.Endpoint,
  secret_key_base: "mmqcFIqKIVtMAVBn1c0u3YO+m6pzRAloZYNNkUQFJr8TxrRrm/rK0v+LCyDPQ4nI"

# Configure your database
config :apientry, Apientry.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "postgres://apientry:fxuJbaisGapsBacroarh@apientry-production.c1snflmeflqw.us-east-1.rds.amazonaws.com:5432/apientry_production",
  pool_size: 10,
  ssl: true

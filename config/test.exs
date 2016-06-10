use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :apientry, Apientry.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
database_url = System.get_env("DATABASE_URL")
if database_url do
  config :apientry, Apientry.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: database_url,
    pool: Ecto.Adapters.SQL.Sandbox
else
  config :apientry, Apientry.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "postgres",
    password: "postgres",
    database: "apientry_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox
end

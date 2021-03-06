use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :apientry, Apientry.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
             cd: Path.expand("../", __DIR__)]]

# Watch static and templates for browser reloading.
config :apientry, Apientry.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex|slim|slime)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

if System.get_env("CRON_ROLE") == "CRON_RUNNER" do
  config :quantum, :apientry,
    cron: [
        "45 */7 * * *":  {"Apientry.DownloadCouponCopyWorker", :perform},
        "* */6 * * *":  {"Apientry.DownloadCouponWorker", :perform},
        "31 */6 * * *":  {"Apientry.DownloadCouponCopyWorker", :perform}
    ]
end

# Configure your database
config :apientry, Apientry.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") ||
    "postgres://postgres:postgres@localhost:5432/apientry_dev",
  pool_size: 10

config :apientry, :amplitude,
  api_key: "c8353e008b3d15a7e584db46a9e44e51"

config :apientry, :rollbar_enabled, false

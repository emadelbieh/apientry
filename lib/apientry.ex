defmodule Apientry do
  @moduledoc false
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Apientry.Endpoint, []),
      # Start the Ecto repository
      supervisor(Apientry.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(Apientry.Worker, [arg1, arg2, arg3]),
      supervisor(Apientry.DbCacheSupervisor, [[name: :db_cache_supervisor]]),
      worker(CsvCacheRegistry, [CsvCacheRegistry]),
      supervisor(CsvCacheSupervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Apientry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Apientry.Endpoint.config_change(changed, removed)
    :ok
  end
end

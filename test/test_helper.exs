ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Apientry.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Apientry.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Apientry.Repo)


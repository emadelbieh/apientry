defmodule Apientry.TestHelpers do
  alias Apientry.Repo

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      email: "foo@bar.baz",
      password: "supersecret"
    }, attrs)
    %Apientry.User{}
    |> Apientry.User.registration_changeset(changes)
    |> Repo.insert!()
  end
end

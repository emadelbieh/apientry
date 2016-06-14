defmodule Apientry.Repo.Migrations.CreatePublisherFeed do
  use Ecto.Migration

  def change do
    create table(:publisher_feeds) do
      add :publisher_id, :integer
      add :feed_id, :integer

      timestamps
    end

    create index(:publisher_feeds, [:publisher_id])
    create index(:publisher_feeds, [:feed_id])
  end
end

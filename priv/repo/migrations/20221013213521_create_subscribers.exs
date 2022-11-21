defmodule Newnix.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :firstname, :string, size: 100
      add :lastname, :string, size: 100

      add :unsubscribed, :boolean

      add :email, :citext, null: false

      add :project_id,
          references(:projects, type: :uuid, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:subscribers, [:email, :project_id])
    create index(:subscribers, [:inserted_at, :id])

    create table(:campaign_subscriber, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :campaign_id,
          references(:campaigns, type: :uuid, on_delete: :delete_all)

      add :subscriber_id,
          references(:subscribers, type: :uuid, on_delete: :delete_all)

      add :firstname, :string, size: 100
      add :lastname, :string, size: 100

      add :subscribed_at, :utc_datetime_usec
      add :unsubscribed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:campaign_subscriber, [:inserted_at, :id])
    create(unique_index(:campaign_subscriber, [:campaign_id, :subscriber_id]))
  end
end

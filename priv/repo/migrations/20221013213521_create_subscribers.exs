defmodule Newnix.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :firstname, :string, size: 100
      add :lastname, :string, size: 100

      add :unsubscribed, :boolean

      add :email, :citext, null: false

      add :project_id, references(:projects, type: :uuid)

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:subscribers, [:email, :project_id])

    create table(:campaign_subscribers, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :campaign_id, references(:campaigns, type: :uuid)
      add :subscriber_id, references(:subscribers, type: :uuid)

      add :firstname, :string, size: 100
      add :lastname, :string, size: 100

      add :subscribed_at, :utc_datetime_usec
      add :unsubscribed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:campaign_subscribers, [:campaign_id, :subscriber_id]))
  end
end

defmodule Newnix.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, size: 50)
      add(:email, :string, size: 50)

      add(:project_id, references(:projects, type: :uuid))

      timestamps()
    end

    create table(:campaign_subscribers, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:subscribed_at, :utc_datetime)

      add(:campaign_id, references(:campaigns, type: :uuid))
      add(:subscriber_id, references(:subscribers, type: :uuid))

      timestamps()
    end

    create(unique_index(:campaign_subscribers, [:campaign_id, :subscriber_id]))
  end
end

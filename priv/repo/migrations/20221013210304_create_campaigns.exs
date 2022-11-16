defmodule Newnix.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 50
      add :description, :string

      add :start_at, :utc_datetime_usec
      add :expire_at, :utc_datetime_usec

      add :status, :string

      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end

    create table(:campaign_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :token, :string, size: 50
      add :read, :boolean
      add :write, :boolean

      add :campaign_id, references(:campaigns, type: :uuid, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end
  end
end

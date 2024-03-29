defmodule Newnix.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :email, :citext, null: false
      add :hashed_password, :string

      add :admin, :bool, default: false

      add :gender, :string, size: 20
      add :firstname, :string, size: 100
      add :lastname, :string, size: 100
      add :phone, :string, size: 20

      # url
      add :avatar, :text

      # active, inactive, suspend, banned
      add :status, :string, size: 10

      add :confirmed_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create table(:identities) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :provider_id, :string, null: false
      add :provider, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:identities, [:provider_id, :provider])
  end
end

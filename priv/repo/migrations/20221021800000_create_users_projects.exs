defmodule Newnix.Repo.Migrations.CreateUsersProjects do
  use Ecto.Migration

  def change do
    create table(:users_projects, primary_key: false) do
      add :role, :string, default: "user"

      add :user_id, references(:users, type: :binary_id)
      add :project_id, references(:projects, type: :binary_id)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:users_projects, [:project_id, :user_id])
  end
end

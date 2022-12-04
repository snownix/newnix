defmodule Newnix.Repo.Migrations.CreateUsersProjects do
  use Ecto.Migration

  def change do
    create table(:users_projects) do
      add :role, :string, default: "user"
      add :status, :string, default: "pending"

      add :user_id,
          references(:users, type: :binary_id, on_delete: :delete_all)

      add :project_id,
          references(:projects, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:users_projects, [:project_id, :user_id])
  end
end

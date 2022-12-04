defmodule Newnix.Repo.Migrations.CreateProjectInvites do
  use Ecto.Migration

  alias Newnix.Projects.Invite

  def change do
    create table(:project_invites, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :email, :citext, null: false
      add :role, :string, default: "user"
      add :expire_at, :utc_datetime_usec

      add :status, :string

      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :sender_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :project_id, references(:projects, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:project_invites, [:user_id])
    create index(:project_invites, [:sender_id])
    create index(:project_invites, [:project_id])

    create unique_index(:project_invites, [:project_id, :email])
  end
end

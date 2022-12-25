defmodule Newnix.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  alias Newnix.Projects.Project

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string, size: Project.maxlen_name()
      add :description, :string, size: Project.maxlen_description()
      add :website, :string, size: Project.maxlen_website()
      add :deleted_at, :utc_datetime_usec

      add :logo, :text

      timestamps(type: :utc_datetime_usec)
    end

    create table(:projects_tokens) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create index(:projects_tokens, [:project_id, :user_id])
    create unique_index(:projects_tokens, [:context, :token])
  end
end

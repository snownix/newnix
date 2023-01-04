defmodule Newnix.Repo.Migrations.CreateProjectIntegrations do
  use Ecto.Migration

  def change do
    create table(:project_integrations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :type, :string, null: false
      add :status, :string, null: false

      add :config, :map, null: false

      add :project_id,
          references(
            :projects,
            on_delete: :delete_all,
            type: :binary_id
          )

      add :user_id,
          references(
            :users,
            on_delete: :delete_all,
            type: :binary_id
          )

      timestamps()
    end

    create index(:project_integrations, [:user_id])
    create index(:project_integrations, [:project_id])
  end
end

defmodule Newnix.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 50
      add :description, :string
      add :website, :string, size: 50

      timestamps()
    end
  end
end

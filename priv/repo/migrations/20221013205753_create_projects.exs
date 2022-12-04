defmodule Newnix.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  alias Newnix.Projects.Project

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string, size: Project.maxlen_name()
      add :description, :string, size: Project.maxlen_description()
      add :website, :string, size: Project.maxlen_website()

      add :logo, :text

      timestamps(type: :utc_datetime_usec)
    end
  end
end

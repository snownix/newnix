defmodule Newnix.Repo.Migrations.CreateBuilderForms do
  use Ecto.Migration

  alias Newnix.Builder.Form

  def change do
    create table(:builder_forms, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :lang, :string
      add :name, :string, size: Form.maxlen_name()
      add :description, :string, size: Form.maxlen_description()
      add :domains, {:array, :string}

      add :firstname, :boolean, default: false, null: false
      add :lastname, :boolean, default: false, null: false
      add :email_text, :string, size: Form.maxlen_email()
      add :button_text, :string, size: Form.maxlen_button()

      add :thanks_text, :string, size: Form.maxlen_thanks()

      add :css, :text
      add :status, :string

      add :project_id,
          references(:projects, type: :binary_id, on_delete: :delete_all)

      add :campaign_id,
          references(:campaigns, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:builder_forms, [:campaign_id])
  end
end

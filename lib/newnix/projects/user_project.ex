defmodule Newnix.Projects.UserProject do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Accounts.User
  alias Newnix.Projects.Project

  @primary_key false
  schema "users_projects" do
    field :role, :string, default: "user"

    belongs_to :user, User, type: :binary_id
    belongs_to :project, Project, type: :binary_id

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:user_id, :project_id])
    |> validate_required([:user_id, :project_id])
  end
end

defmodule Newnix.Projects.UserProject do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Accounts.User
  alias Newnix.Projects.Project

  @timestamps_opts [type: :utc_datetime_usec]

  schema "users_projects" do
    field :role, Ecto.Enum, values: [:owner, :admin, :user], default: :user
    field :status, Ecto.Enum, values: [:active, :inactive, :suspend, :pending], default: :pending

    belongs_to :user, User, type: :binary_id
    belongs_to :project, Project, type: :binary_id

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:role, :status])
    |> validate_required([:user, :project, :role, :status])
  end

  def project_assoc(changeset, project) do
    changeset
    |> change()
    |> put_assoc(:project, project)
  end

  def user_assoc(changeset, user) do
    changeset
    |> change()
    |> put_assoc(:user, user)
  end
end

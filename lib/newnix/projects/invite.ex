defmodule Newnix.Projects.Invite do
  @doc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Newnix.Repo

  alias Newnix.Accounts.User
  alias Newnix.Projects.Project

  @roles [:admin, :manager, :user]

  @maxlen_email 225
  def maxlen_email(), do: @maxlen_email

  @policies %{
    list: [:admin, :manager, :user],
    create: [:admin],
    update: [:admin],
    delete: [:admin]
  }
  def policies(), do: @policies

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "project_invites" do
    field :email, :string
    field :role, Ecto.Enum, values: @roles, default: :user
    field :status, Ecto.Enum, values: [:pending, :accepted, :rejected], default: :pending

    belongs_to :user, User
    belongs_to :sender, User
    belongs_to :project, Project

    field :expire_at, :utc_datetime_usec

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:email, :expire_at])
    |> validate_required([:email, :expire_at])
    |> unique_constraint([:project_id, :email])
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
    |> validate_available_email()
  end

  def sender_assoc(changeset, sender) do
    changeset
    |> put_assoc(:sender, sender)
  end

  def user_assoc(changeset, user) do
    changeset
    |> put_assoc(:user, user)
  end

  def answer(invite, :accept) do
    invite |> change(%{status: :accepted})
  end

  def answer(invite, :reject) do
    invite |> change(%{status: :rejected})
  end

  def expire_at(changeset) do
    get_field(changeset, :expire_at) |> Timex.format!("{relative}", :relative)
  end

  def validate_available_email(changeset) do
    validate_change(changeset, :email, :unique_email_per_project, fn _field, email ->
      project_id = get_field(changeset, :project_id)

      project_id = if is_nil(project_id), do: get_field(changeset, :project), else: project_id

      if email_in_project?(email, project_id) do
        [project_id: "Email already invited"]
      else
        []
      end
    end)
  end

  def email_in_project?(nil, _), do: false
  def email_in_project?(_email, nil), do: false

  def email_in_project?(email, %{id: project_id}), do: email_in_project?(email, project_id)

  def email_in_project?(email, project_id) do
    query =
      from p in Project,
        join: u in assoc(p, :users),
        where: p.id == ^project_id and u.email == ^email,
        select: 1

    not is_nil(Repo.one(query))
  end
end

defmodule Newnix.Projects.Project do
  use Ecto.Schema

  alias Newnix.Accounts.User
  alias Newnix.Projects.Invite

  alias Newnix.Builder.Form
  alias Newnix.Campaigns.Campaign
  alias Newnix.Subscribers.Subscriber

  alias Newnix.Projects.UserProject

  import Ecto.Changeset

  @policies %{
    update: [:admin],
    settings: [:admin]
  }
  def policies(), do: @policies

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field :name, :string
    field :website, :string
    field :description, :string

    field :logo, Newnix.Uploaders.LogoUploader.Type

    has_many :forms, Form
    has_many :invites, Invite
    has_many :campaigns, Campaign
    has_many :subscribers, Subscriber

    has_one :role, UserProject
    many_to_many :users, User, join_through: UserProject

    has_many :users_projects, UserProject

    timestamps()
  end

  @maxlen_name 40
  def maxlen_name(), do: @maxlen_name
  @maxlen_description 500
  def maxlen_description(), do: @maxlen_description
  @maxlen_website 500
  def maxlen_website(), do: @maxlen_website

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :website])
    |> cast_assoc(:forms)
    |> cast_assoc(:campaigns)
    |> validate_required([:name])
    |> validate_length(:name, max: @maxlen_name)
    |> validate_length(:description, max: @maxlen_description)
    |> validate_length(:website, max: @maxlen_website)
  end

  def user_assoc(project, user) do
    project
    |> change()
    |> put_assoc(:users, [user])
  end

  def owner_changeset(project, user) do
    users_projects = project.users_projects

    user_project = users_projects |> Enum.find(&(&1.user_id == user.id))

    user_project =
      if user_project do
        user_project
      else
        %UserProject{project: project, user: user, role: :owner}
      end

    users_projects =
      [user_project | users_projects]
      |> Enum.uniq_by(fn %{user_id: a, project_id: b} -> {a, b} end)

    project
    |> change()
    |> put_assoc(:users_projects, users_projects)
  end
end

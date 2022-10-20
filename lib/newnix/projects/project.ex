defmodule Newnix.Projects.Project do
  use Ecto.Schema

  alias Newnix.Accounts.User
  alias Newnix.Campaigns.Campaign
  alias Newnix.Subscribers.Subscriber

  alias Newnix.Projects.UserProject

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field :name, :string
    field :description, :string
    field :website, :string

    has_many :campaigns, Campaign
    has_many :subscribers, Subscriber
    many_to_many :users, User, join_through: UserProject

    timestamps()
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :website])
    |> validate_required([:name])
  end

  def user_assoc(project, user) do
    project
    |> change()
    |> put_assoc(:users, [user])
  end
end

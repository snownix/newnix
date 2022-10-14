defmodule Newnix.Projects.Project do
  use Ecto.Schema

  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.Campaign

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field :name, :string
    field :description, :string
    field :website, :string

    has_many :subscribers, Subscriber
    has_many :campaigns, Campaign

    timestamps()
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :website])
    |> validate_required([:name])
  end
end

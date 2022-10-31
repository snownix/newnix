defmodule Newnix.Campaigns.Campaign do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Projects.Project
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.{CampaignToken, CampaignSubscriber}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "campaigns" do
    field :name, :string
    field :description, :string
    field :start_at, :utc_datetime
    field :expire_at, :utc_datetime
    field :status, Ecto.Enum, values: []
    field :subscribers_count, :integer, virtual: true, default: 0

    belongs_to :project, Project, type: :binary_id
    has_many :tokens, CampaignToken
    many_to_many :subscribers, Subscriber, join_through: CampaignSubscriber

    timestamps()
  end

  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, [:name, :description, :start_at, :expire_at, :status])
    |> validate_required([:name])
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
  end
end

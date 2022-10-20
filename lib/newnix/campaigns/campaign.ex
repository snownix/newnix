defmodule Newnix.Campaigns.Campaign do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Projects.Project
  alias Newnix.Campaigns.{CampaignToken, CampaignSubscriber}
  alias Newnix.Subscribers.Subscriber

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "campaigns" do
    field :name, :string
    field :description, :string
    field :expire_at, :utc_datetime
    field :status, Ecto.Enum, values: []

    belongs_to :project, Project
    has_many :tokens, CampaignToken
    many_to_many :subscribers, Subscriber, join_through: CampaignSubscriber

    timestamps()
  end

  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, [:name, :description, :expire_at, :status])
    |> validate_required([:name, :expire_at])
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
  end
end

defmodule Newnix.Subscribers.Subscriber do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Projects.Project
  alias Newnix.Campaigns.Campaign
  alias Newnix.Campaigns.CampaignSubscriber

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "subscribers" do
    field :firstname, :string
    field :lastname, :string

    field :email, :string
    field :unsubscribed, :boolean

    belongs_to :project, Project, type: :binary_id
    many_to_many :campaigns, Campaign, join_through: CampaignSubscriber

    timestamps()
  end

  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:firstname, :lastname, :email, :unsubscribed])
    |> validate_required([:email])
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
  end

  def campaign_assoc(changeset, campaign) do
    changeset
    |> put_assoc(:campaign, [campaign])
  end
end

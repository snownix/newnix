defmodule Newnix.Subscribers.Subscriber do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Projects.Project
  alias Newnix.Campaigns.Campaign
  alias Newnix.Campaigns.CampaignSubscriber

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "subscribers" do
    field :name, :string
    field :email, :boolean

    belongs_to :project, Project
    many_to_many :campaigns, Campaign, join_through: CampaignSubscriber

    timestamps()
  end

  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end

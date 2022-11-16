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
    field :start_at, :utc_datetime_usec
    field :expire_at, :utc_datetime_usec

    field :status, Ecto.Enum,
      values: [:active, :inactive, :expired, :paused, :finished],
      default: :active

    belongs_to :project, Project, type: :binary_id
    has_many :tokens, CampaignToken

    many_to_many :subscribers, Subscriber,
      join_through: CampaignSubscriber,
      on_delete: :delete_all

    has_many :campaign_subscriber, CampaignSubscriber,
      on_replace: :delete,
      on_delete: :delete_all

    field :subscribers_count, :integer, virtual: true, default: 0
    field :unsubscribers_count, :integer, virtual: true, default: 0

    timestamps()
  end

  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, [:name, :description, :start_at, :expire_at, :status])
    |> cast_assoc(:subscribers)
    |> cast_assoc(:campaign_subscriber)
    |> validate_required([:name])
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
  end

  # "TODO:: check if between start & end(time left/progress), after end(expired), before start(ago),"
  def campaign_status(_campaign) do
    ""
  end
end

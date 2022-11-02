defmodule Newnix.Campaigns.CampaignSubscriber do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.Campaign

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "campaign_subscribers" do
    field :firstname, :string
    field :lastname, :string

    field :unsubscribed_at, :utc_datetime

    belongs_to :campaign, Campaign, type: :binary_id
    belongs_to :subscriber, Subscriber, type: :binary_id

    timestamps()
  end

  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:unsubscribed_at])
    |> unique_constraint([:campaign_id, :subscriber_id])
  end
end

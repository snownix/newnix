defmodule Newnix.Campaigns.CampaignSubscriber do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.Campaign

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "campaign_subscribers" do
    field :subscribed_at, :utc_datetime

    belongs_to :campaign, Campaign, type: :binary_id
    belongs_to :subscriber, Subscriber, type: :binary_id

    timestamps()
  end

  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:subscribed_at])
    |> validate_required([:subscribed_at])
  end
end

defmodule Newnix.Campaigns.CampaignSubscriber do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.Campaign

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "campaign_subscribers" do
    field :firstname, :string
    field :lastname, :string

    field :subscribed_at, :utc_datetime_usec
    field :unsubscribed_at, :utc_datetime_usec

    belongs_to :campaign, Campaign, type: :binary_id
    belongs_to :subscriber, Subscriber, type: :binary_id

    timestamps()
  end

  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:unsubscribed_at, :firstname, :lastname])
    |> unique_constraint([:campaign_id, :subscriber_id, :subscribed_at])
  end
end

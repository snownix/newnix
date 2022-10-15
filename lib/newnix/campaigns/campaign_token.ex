defmodule Newnix.Campaigns.CampaignToken do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Campaigns.Campaign

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "campaign_tokens" do
    field :token, :string
    field :read, :boolean
    field :write, :boolean

    belongs_to :campaign, Campaign

    timestamps()
  end

  def changeset(campaign_token, attrs) do
    campaign_token
    |> cast(attrs, [:token, :read, :write])
    |> validate_required([:token])
  end
end

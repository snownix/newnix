defmodule Newnix.Subscribers.Subscriber do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Projects.Project
  alias Newnix.Campaigns.Campaign
  alias Newnix.Campaigns.CampaignSubscriber

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "subscribers" do
    field :firstname, :string
    field :lastname, :string

    field :email, :string
    field :unsubscribed, :boolean

    belongs_to :project, Project, type: :binary_id

    has_many :campaign_subscriber, CampaignSubscriber,
      on_replace: :delete,
      on_delete: :delete_all

    many_to_many :campaigns, Campaign,
      join_through: CampaignSubscriber,
      on_delete: :delete_all,
      on_replace: :delete

    field :campaign_id, :binary_id, virtual: true
    field :subscribed_at, :utc_datetime_usec, virtual: true
    field :unsubscribed_at, :utc_datetime_usec, virtual: true

    timestamps()
  end

  def changeset(subscriber, attrs \\ %{}, opts \\ []) do
    subscriber
    |> cast(attrs, [:firstname, :lastname, :email, :unsubscribed])
    |> validate_required([:email])
    |> do_validate_required(:firstname, Keyword.get(opts, :firstname, false))
    |> do_validate_required(:lastname, Keyword.get(opts, :lastname, false))
    |> unique_constraint([:email, :project_id])
  end

  def do_validate_required(changeset, field, true), do: changeset |> validate_required(field)
  def do_validate_required(changeset, _field, false), do: changeset

  def project_assoc(changeset, project) do
    changeset
    |> change()
    |> put_assoc(:project, project)
  end

  def campaigns_assoc(changeset, campaigns \\ []) do
    changeset
    |> change()
    |> put_assoc(:campaign_subscriber, campaigns)
  end

  def get_email(changeset), do: get_field(changeset, :email)
  def get_campaign(changeset), do: get_field(changeset, :campaign)
end

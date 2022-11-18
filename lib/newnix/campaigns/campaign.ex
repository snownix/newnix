defmodule Newnix.Campaigns.Campaign do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Projects.Project
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.{Campaign, CampaignToken, CampaignSubscriber}

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

  def campaign_status(%Campaign{} = campaign) do
    %{start_at: start_at, expire_at: expire_at} = campaign

    today = DateTime.utc_now()

    case {start_at, expire_at} do
      {nil, nil} ->
        :active

      {nil, end_date} ->
        if Timex.Comparable.compare(today, end_date) > -1 do
          :expired
        else
          :active
        end

      {start_date, nil} ->
        if Timex.Comparable.compare(start_date, today) > -1 do
          :future
        else
          :active
        end

      {start_date, end_date} ->
        cond do
          Timex.Comparable.compare(today, start_date) > -1 and
              Timex.Comparable.compare(end_date, today) > -1 ->
            :active

          Timex.Comparable.compare(start_date, today) > -1 ->
            :future

          Timex.Comparable.compare(today, end_date) > -1 ->
            :expired

          true ->
            :draft
        end
    end
  end
end

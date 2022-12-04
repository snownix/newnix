defmodule Newnix.Campaigns.Campaign do
  use Ecto.Schema

  import Ecto.Changeset

  alias Newnix.Projects.Project
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.{Campaign, CampaignToken, CampaignSubscriber}

  @policies %{
    list: [:admin, :manager, :user],
    create: [:admin, :manager, :user],
    update: [:admin, :manager, :user],
    delete: [:admin, :manager]
  }
  def policies(), do: @policies

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

  @maxlen_name 40
  def maxlen_name(), do: @maxlen_name
  @maxlen_description 500
  def maxlen_description(), do: @maxlen_description

  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, [:name, :description, :start_at, :expire_at, :status])
    |> cast_assoc(:subscribers)
    |> cast_assoc(:campaign_subscriber)
    |> validate_required([:name])
    |> validate_length(:name, max: @maxlen_name)
    |> validate_length(:description, max: @maxlen_description)
    |> validate_campaign_dates()
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
  end

  def campaign_status(%Ecto.Changeset{} = changeset) do
    campaign_status(%Campaign{
      start_at: get_field(changeset, :start_at),
      expire_at: get_field(changeset, :expire_at)
    })
  end

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

  def campaign_status(_), do: ""

  defp validate_campaign_dates(changeset) do
    start_at = get_field(changeset, :start_at)
    expire_at = get_field(changeset, :expire_at)

    if !is_nil(start_at) and !is_nil(expire_at) and Date.compare(start_at, expire_at) == :gt do
      add_error(changeset, :start_at, "Start date cannot be later than end date")
    else
      changeset
    end
  end
end

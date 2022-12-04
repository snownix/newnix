defmodule Newnix.Subscribers do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  import Ecto.Changeset, only: [get_field: 2]

  alias Newnix.Repo
  alias Newnix.Pagination
  alias Newnix.Projects.Project
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.Campaign
  alias Newnix.Campaigns.CampaignSubscriber

  @topic inspect(__MODULE__)

  def subscribe(project_id) do
    Phoenix.PubSub.subscribe(Newnix.PubSub, "#{@topic}:#{project_id}")
  end

  def subscribe(project_id, id) do
    Phoenix.PubSub.subscribe(Newnix.PubSub, "#{@topic}:#{project_id}:#{id}")
  end

  def notify_subscribers({:ok, %{project_id: project_id} = result}, event) do
    notify_subscribers(project_id, result, event)
  end

  def notify_subscribers({:error, reason}, _), do: {:error, reason}

  def notify_subscribers(project_id, result, event) do
    Phoenix.PubSub.broadcast(
      Newnix.PubSub,
      "#{@topic}:#{project_id}",
      {__MODULE__, event, result}
    )

    Phoenix.PubSub.broadcast(
      Newnix.PubSub,
      "#{@topic}:#{project_id}:#{result.id}",
      {__MODULE__, event, result}
    )

    {:ok, result}
  end

  @doc """
  Returns the list of subscribers.

  ## Examples

      iex> list_subscribers()
      [%Menu{}, ...]

  """
  def list_subscribers(project = %Project{}, opts \\ []) do
    query =
      from(
        s in Subscriber,
        left_join: cs in CampaignSubscriber,
        on: cs.subscriber_id == s.id,
        where: s.project_id == ^project.id,
        select_merge: %{
          subscribed_at: cs.subscribed_at,
          unsubscribed_at: cs.unsubscribed_at,
          campaign_id: cs.campaign_id
        }
      )
      |> all_subscribers(Keyword.get(opts, :all, true))
      |> order_subscribers(Keyword.get(opts, :sort, :desc), Keyword.get(opts, :order))

    Pagination.all(query, opts)
  end

  defp all_subscribers(query, true), do: query

  defp all_subscribers(query, false) do
    query
    |> where([_s, cs], is_nil(cs.unsubscribed_at))
  end

  defp order_subscribers(query, sort, :inserted_at) do
    query
    |> order_by([s, cs], [
      {^sort, cs.subscribed_at},
      {^sort, cs.inserted_at},
      {^sort, s.inserted_at}
    ])
  end

  defp order_subscribers(query, _, _), do: query

  def meta_list_subscribers(project = %Project{}) do
    query =
      from p in Subscriber,
        where: p.project_id == ^project.id,
        select: p.name

    Repo.all(query)
  end

  @doc """
  Gets a single subscriber.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.

  ## Examples

      iex> get_subscriber!(project, 123)
      %Subscriber{}

      iex> get_subscriber!(project, 456)
      ** (Ecto.NoResultsError)

  """
  def get_subscriber!(project = %Project{}, id) do
    query =
      from c in Subscriber,
        where: c.id == ^id and c.project_id == ^project.id

    Repo.one!(query)
  end

  def get_subscriber_by_email!(project = %Project{}, email) do
    query =
      from c in Subscriber,
        where: c.email == ^email and c.project_id == ^project.id,
        preload: [:campaigns, :campaign_subscriber]

    Repo.one!(query)
  end

  def get_subscription_by_email(campaign = %Campaign{}, email) do
    query =
      from cs in CampaignSubscriber,
        join: s in Subscriber,
        on: s.id == cs.subscriber_id,
        where: s.email == ^email and cs.campaign_id == ^campaign.id

    Repo.one(query)
  end

  @doc """
  fetch subscriber campaigns.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.

  ## Examples

      iex> fetch_campaigns(%Subscriber{})
      %Subscriber{}

      iex> fetch_campaigns(%Subscriber{})
      ** (Ecto.NoResultsError)

  """
  def fetch_campaigns(%Subscriber{} = subscriber) do
    subscriber
    |> Repo.preload(:campaign_subscriber)
    |> Repo.preload(:campaigns)
  end

  @doc """
  Creates a subscriber.

  ## Examples

      iex> create_subscriber(user, %{field: value})
      {:ok, %Subscriber{}}

      iex> create_subscriber(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscriber(%Project{} = project, attrs) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Subscriber.project_assoc(project)
    |> Repo.insert()
  end

  def create_subscriber(%Campaign{} = campaign, attrs) do
    campaign =
      campaign
      |> Repo.preload(:project)

    create_subscriber(campaign.project, campaign, attrs)
  end

  def create_subscriber(%Project{} = project, campaign = %Campaign{}, attrs) do
    cs_attrs =
      Map.merge(
        %{
          "subscribed_at" => DateTime.utc_now()
        },
        Map.take(attrs, ["firstname", "lastname"])
      )

    campaign_subscriber_assoc =
      CampaignSubscriber.changeset(%CampaignSubscriber{}, cs_attrs)
      |> CampaignSubscriber.campaign_assoc(campaign)

    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Subscriber.project_assoc(project)
    |> insert_or_modify(project, campaign_subscriber_assoc)
  end

  def create_subscriber(%Project{} = project, nil, attrs), do: create_subscriber(project, attrs)

  @doc """
  Updates a subscriber.

  ## Examples

      iex> update_subscriber(subscriber, %{field: new_value})
      {:ok, %Subscriber{}}

      iex> update_subscriber(subscriber, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscriber(%Subscriber{} = subscriber, attrs) do
    subscriber
    |> Subscriber.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:subscriber, :updated])
  end

  def update_subscriber(%Subscriber{} = subscriber, %Campaign{} = campaign, attrs) do
    subscriber = subscriber |> Repo.preload(:campaign_subscriber)

    campaigns =
      Map.get(subscriber, :campaign_subscriber, [])
      |> Enum.map(fn ca ->
        if ca.campaign_id == campaign.id do
          fields = Map.take(attrs, ["firstname", "lastname"])

          CampaignSubscriber.changeset(
            %CampaignSubscriber{
              campaign: campaign
            },
            fields
          )
        else
          ca
        end
      end)

    attrs =
      attrs
      |> Map.delete("firstname")
      |> Map.delete("lastname")

    subscriber
    |> Subscriber.changeset(attrs)
    |> Subscriber.campaigns_assoc(campaigns)
    |> Repo.update()
    |> notify_subscribers([:subscriber, :updated])
  end

  def update_subscriber(%Subscriber{} = subscriber, nil, attrs),
    do: update_subscriber(%Subscriber{} = subscriber, attrs)

  @doc """
  Deletes a subscriber.

  ## Examples

      iex> delete_subscriber(subscriber)
      {:ok, %Subscriber{}}

      iex> delete_subscriber(subscriber)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscriber(%Subscriber{} = subscriber) do
    Repo.delete(subscriber)
    |> notify_subscribers([:subscriber, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriber changes.

  ## Examples

      iex> change_subscriber(subscriber)
      %Ecto.Changeset{data: %Subscriber{}}

  """
  def change_subscriber(%Subscriber{} = subscriber, attrs \\ %{}, opts \\ []) do
    Subscriber.changeset(subscriber, attrs, opts)
  end

  @doc """
  Deletes a subscriber from campaign.

  ## Examples

      iex> delete_subscriber_from_campaign(subscriber, campaign)
      {:ok, %Subscriber{}}

      iex> delete_subscriber_from_campaign(subscriber, campaign)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscriber_from_campaign(%Subscriber{} = subscriber, %Campaign{} = campaign) do
    subscriber = Repo.preload(subscriber, :campaigns)

    campaigns = Enum.filter(subscriber.campaigns, &(&1.id !== campaign.id))

    subscriber
    |> Subscriber.campaigns_assoc(campaigns)
    |> Repo.update()
    |> notify_subscribers([:subscriber, :deleted])
  end

  @doc """
  unsubscribe a subscriber from campaign.

  ## Examples

      iex> unsubscribe_from_campaign(subscriber, campaign)
      {:ok, %Subscriber{}}

      iex> unsubscribe_from_campaign(subscriber, campaign)
      {:error, %Ecto.Changeset{}}

  """
  def unsubscribe_from_campaign(%Subscriber{} = subscriber, %Campaign{} = campaign) do
    query =
      from cs in CampaignSubscriber,
        where:
          cs.campaign_id == ^campaign.id and
            cs.subscriber_id == ^subscriber.id

    Repo.update_all(
      query,
      set: [unsubscribed_at: DateTime.utc_now()]
    )
  end

  @doc """
  resubscribe a subscriber from campaign.

  ## Examples

      iex> resubscribe_from_campaign(subscriber, campaign)
      {:ok, %Subscriber{}}

      iex> resubscribe_from_campaign(subscriber, campaign)
      {:error, %Ecto.Changeset{}}

  """
  def resubscribe_from_campaign(%Subscriber{} = subscriber, %Campaign{} = campaign) do
    query =
      from cs in CampaignSubscriber,
        where:
          cs.campaign_id == ^campaign.id and
            cs.subscriber_id == ^subscriber.id

    Repo.update_all(
      query,
      set: [unsubscribed_at: nil]
    )
  end

  def insert_or_modify(changeset, %Project{} = project, list_campaign_subscriber \\ nil) do
    changeset
    |> Subscriber.project_assoc(project)
    |> Subscriber.campaigns_assoc([list_campaign_subscriber])
    |> Repo.insert()
    |> case do
      {:ok, subscriber} ->
        {:ok, subscriber} |> notify_subscribers([:subscriber, :created])

      {:error, _error} ->
        email = Subscriber.get_email(changeset)
        campaign = Subscriber.get_campaign(list_campaign_subscriber)

        case get_subscription_by_email(campaign, email) do
          nil ->
            subscriber = get_subscriber_by_email!(project, email)

            subscriber
            |> Subscriber.changeset()
            |> Subscriber.campaigns_assoc([
              list_campaign_subscriber | subscriber.campaign_subscriber
            ])
            |> Repo.update()
            |> notify_subscribers([:subscriber, :updated])

          subscription ->
            CampaignSubscriber.changeset(subscription, %{
              "subscribed_at" => DateTime.utc_now(),
              "unsubscribed_at" => nil
            })
            |> Repo.update()
            |> case do
              {:ok, subscription} ->
                subscription
                |> Repo.preload(:subscriber)
                |> then(&{:ok, &1.subscriber})
                |> notify_subscribers([:subscriber, :updated])

              other ->
                other
            end
        end
    end
  end
end

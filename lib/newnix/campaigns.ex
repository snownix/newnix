defmodule Newnix.Campaigns do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Newnix.Repo
  alias Newnix.Pagination
  alias Newnix.Projects.Project
  alias Newnix.Campaigns.Campaign
  alias Newnix.Campaigns.CampaignSubscriber
  alias Newnix.Subscribers.Subscriber

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Newnix.PubSub, @topic)
  end

  def subscribe(project_id) do
    Phoenix.PubSub.subscribe(Newnix.PubSub, "#{@topic}:#{project_id}")
  end

  def subscribe(project_id, row_id) do
    Phoenix.PubSub.subscribe(Newnix.PubSub, "#{@topic}:#{project_id}:#{row_id}")
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(
      Newnix.PubSub,
      "#{@topic}:#{result.project_id}",
      {__MODULE__, event, result}
    )

    Phoenix.PubSub.broadcast(
      Newnix.PubSub,
      "#{@topic}:#{result.project_id}:#{result.id}",
      {__MODULE__, event, result}
    )

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _), do: {:error, reason}

  @doc """
  Returns the list of campaigns.

  ## Examples

      iex> list_campaigns()
      [%Menu{}, ...]

  """
  def list_campaigns(project = %Project{}, opts \\ []) do
    query =
      from(c in Campaign,
        left_join: cs in CampaignSubscriber,
        on: cs.campaign_id == c.id,
        where: c.project_id == ^project.id,
        select:
          merge(c, %{
            unsubscribers_count: count(cs.unsubscribed_at),
            subscribers_count:
              fragment(
                "COUNT(DISTINCT(CASE WHEN ? IS NULL AND ? IS NOT NULL THEN (?,?) ELSE NULL END))",
                cs.unsubscribed_at,
                cs.campaign_id,
                cs.subscriber_id,
                cs.campaign_id
              )
              |> selected_as(:subscribers_count)
          }),
        group_by: c.id
      )
      |> order_campaigns(Keyword.get(opts, :sort, :desc), Keyword.get(opts, :order, :inserted_at))

    Pagination.all(query, opts)
  end

  defp order_campaigns(query, sort, :subscribers_count) do
    query
    |> order_by([_c, _cs], [
      {^sort, selected_as(:subscribers_count)}
    ])
  end

  defp order_campaigns(query, _, _), do: query

  def meta_list_campaigns(project = %Project{}) do
    from(
      p in Campaign,
      where: p.project_id == ^project.id,
      select: [:id, :name],
      order_by: {:desc, p.inserted_at}
    )
    |> Repo.all()
  end

  @doc """
  Gets a single campaign.

  Raises `Ecto.NoResultsError` if the Campaign does not exist.

  ## Examples

      iex> get_campaign!(project, 123)
      %Campaign{}

      iex> get_campaign!(project, 456)
      ** (Ecto.NoResultsError)

  """
  def get_campaign!(project = %Project{}, id) do
    query =
      from c in Campaign,
        where: c.id == ^id and c.project_id == ^project.id

    Repo.one!(query)
  end

  @doc """
  Creates a campaign.

  ## Examples

      iex> create_campaign(user, %{field: value})
      {:ok, %Campaign{}}

      iex> create_campaign(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_campaign(project = %Project{}, attrs \\ %{}) do
    %Campaign{}
    |> Campaign.changeset(attrs)
    |> Campaign.project_assoc(project)
    |> Repo.insert()
    |> notify_subscribers([:campaign, :created])
  end

  @doc """
  Updates a campaign.

  ## Examples

      iex> update_campaign(campaign, %{field: new_value})
      {:ok, %Campaign{}}

      iex> update_campaign(campaign, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_campaign(%Campaign{} = campaign, attrs) do
    campaign
    |> Campaign.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:campaign, :updated])
  end

  @doc """
  Deletes a campaign.

  ## Examples

      iex> delete_campaign(campaign)
      {:ok, %Campaign{}}

      iex> delete_campaign(campaign)
      {:error, %Ecto.Changeset{}}

  """
  def delete_campaign(%Campaign{} = campaign) do
    Repo.delete(campaign)
    |> notify_subscribers([:campaign, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking campaign changes.

  ## Examples

      iex> change_campaign(campaign)
      %Ecto.Changeset{data: %Campaign{}}

  """
  def change_campaign(%Campaign{} = campaign, attrs \\ %{}) do
    Campaign.changeset(campaign, attrs)
  end

  @doc """
  Returns the list of subscribers.

  ## Examples

      iex> list_subscribers(%Campaign{}, limit: 50)
      %{entries: [%Subscriber{}, ...], metadata: %{}}

  """
  def list_subscribers(campaign = %Campaign{}, opts \\ []) do
    query =
      from(
        s in Subscriber,
        join: cs in CampaignSubscriber,
        on: cs.subscriber_id == s.id,
        where: cs.campaign_id == ^campaign.id,
        select_merge: %{
          firstname: coalesce(cs.firstname, s.firstname),
          lastname: coalesce(cs.lastname, s.lastname),
          unsubscribed_at: cs.unsubscribed_at,
          subscribed_at: cs.subscribed_at
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

  @doc """
  Gets a single campaign.

  Raises `Ecto.NoResultsError` if the Campaign does not exist.

  ## Examples

      iex> get_campaign_subscriber!(campaign, "a-b-c-d")
      %Campaign{}

      iex> get_campaign_subscriber!(campaign, "a-b-c-d")
      ** (Ecto.NoResultsError)

  """
  def get_campaign_subscriber!(campaign = %Campaign{}, id) do
    from(
      s in Subscriber,
      join: cs in CampaignSubscriber,
      where:
        cs.campaign_id == ^campaign.id and
          cs.subscriber_id == s.id and
          cs.subscriber_id == ^id,
      select_merge: %{
        firstname: coalesce(cs.firstname, s.firstname),
        lastname: coalesce(cs.lastname, s.lastname),
        unsubscribed_at: cs.unsubscribed_at
      }
    )
    |> Repo.one!()
  end

  def subscribers_stats(%Project{} = project, campaigns_id \\ [], opts \\ []) do
    start_date = Keyword.get(opts, :start_date, nil)

    from(
      s in Subscriber,
      join: cs in CampaignSubscriber,
      join: c in Campaign,
      on: cs.subscriber_id == s.id and cs.campaign_id == c.id,
      where: ^with_project_campaigns(project, campaigns_id, start_date),
      select: %{
        unsubscribers: count(cs.unsubscribed_at),
        subscribers:
          fragment(
            "COUNT(DISTINCT(CASE WHEN ? IS NULL THEN (?,?) ELSE NULL END))",
            cs.unsubscribed_at,
            cs.subscriber_id,
            cs.campaign_id
          )
      }
    )
    |> Repo.one()
  end

  defp with_project_campaigns(project, campaigns_id, start_date) do
    dynamic(
      [s, cs, c],
      cs.campaign_id in ^campaigns_id and
        c.project_id == ^project.id and
        ^with_start_date(start_date)
    )
  end

  @doc """
    Returns the stats of campaign subscribers in a period of time.

    ## Examples

        iex> subscribers_chart_stats(%Project{} = project, ["aaaaa-bbbbb-ccccc-ddddd"])
        [%{
          unsubscribers: 10,
          subscribers: 10,
          day_date: "01-12-2022"
        }, ...]
  """
  def subscribers_chart_stats(%Project{} = project, campaigns_id \\ [], opts \\ []) do
    start_date = Keyword.get(opts, :start_date, nil)
    date_format = to_char_format(Keyword.get(opts, :format_date, :days))

    from(
      s in Subscriber,
      join: cs in CampaignSubscriber,
      join: c in Campaign,
      on: cs.subscriber_id == s.id and cs.campaign_id == c.id,
      where: ^with_project_campaigns(project, campaigns_id, start_date),
      select: %{
        unsubscribers: count(cs.unsubscribed_at),
        subscribers:
          fragment(
            "COUNT(DISTINCT(CASE WHEN ? IS NULL THEN (?,?) ELSE NULL END))",
            cs.unsubscribed_at,
            cs.subscriber_id,
            cs.campaign_id
          ),
        day_date:
          selected_as(fragment("to_char(?, ?)", cs.subscribed_at, ^date_format), :day_date)
      },
      group_by: selected_as(:day_date)
    )
    |> Repo.all()
  end

  def with_start_date(nil), do: true
  def with_start_date(start_date), do: dynamic([s, cs, c], cs.subscribed_at >= ^start_date)

  def to_char_format(:hours), do: "HH"
  def to_char_format(:days), do: "DD-MM-YYYY"
  def to_char_format(:months), do: "MM-YYYY"
end

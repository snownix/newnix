defmodule Newnix.Subscribers do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  import Ecto.Changeset, only: [get_field: 2]

  alias Newnix.Repo
  alias Newnix.Projects.Project
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns.Campaign

  @doc """
  Returns the list of subscribers.

  ## Examples

      iex> list_subscribers()
      [%Menu{}, ...]

  """
  def list_subscribers(project = %Project{}, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    query =
      from(
        s in Subscriber,
        where: s.project_id == ^project.id
      )
      |> IO.inspect()

    Repo.paginate(
      query,
      cursor_fields: [:inserted_at, :id],
      limit: Repo.secure_allowed_limit(limit)
    )
  end

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
        preload: [:campaigns, :campaign_subscribers]

    Repo.one!(query)
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
    subscriber |> Repo.preload(:campaigns)
  end

  @doc """
  Creates a subscriber.

  ## Examples

      iex> create_subscriber(user, %{field: value})
      {:ok, %Subscriber{}}

      iex> create_subscriber(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_subscriber(%Project{} = project, attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Subscriber.project_assoc(project)
    |> insert_or_modify(project)
  end

  def create_subscriber(%Project{} = project, campaign = %Campaign{}, attrs) do
    campaign_subscriber_assoc = Map.merge(%{campaign: campaign}, take_names(attrs))

    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Subscriber.project_assoc(project)
    |> insert_or_modify(project, [campaign_subscriber_assoc])
  end

  def create_subscriber(%Project{} = project, nil, attrs), do: create_subscriber(project, attrs)

  defp take_names(%{"firstname" => firstname, "lastname" => lastname} = _attrs),
    do: %{firstname: firstname, lastname: lastname}

  defp take_names(%{"lastname" => lastname} = _attrs), do: %{lastname: lastname}
  defp take_names(%{"firstname" => firstname} = _attrs), do: %{firstname: firstname}
  defp take_names(_), do: %{}

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
  end

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
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriber changes.

  ## Examples

      iex> change_subscriber(subscriber)
      %Ecto.Changeset{data: %Subscriber{}}

  """
  def change_subscriber(%Subscriber{} = subscriber, attrs \\ %{}) do
    Subscriber.changeset(subscriber, attrs)
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
  end

  def insert_or_modify(changeset, %Project{} = project, list_campaign_subscriber \\ []) do
    changeset
    |> Repo.insert()
    |> case do
      {:ok, subscriber} ->
        {:ok, subscriber}

      {:error, _} ->
        email = get_field(changeset, :email)

        subscriber = get_subscriber_by_email!(project, email)
        campaigns = Map.get(subscriber, :campaign_subscribers, [])

        subscriber
        |> Subscriber.changeset()
        |> Subscriber.campaigns_assoc(list_campaign_subscriber ++ campaigns)
        |> Repo.update()
    end
  end
end

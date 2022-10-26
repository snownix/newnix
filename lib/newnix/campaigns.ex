defmodule Newnix.Campaigns do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Newnix.Repo
  alias Newnix.Projects.Project
  alias Newnix.Campaigns.Campaign

  @doc """
  Returns the list of campaigns.

  ## Examples

      iex> list_campaigns()
      [%Menu{}, ...]

  """
  def list_campaigns(project = %Project{}) do
    project
    |> Repo.preload(:campaigns)
    |> then(fn p -> p.campaigns end)
  end

  def meta_list_campaigns(project = %Project{}) do
    query =
      from p in Campaign,
        where: p.project_id == ^project.id,
        select: p.name

    Repo.all(query)
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
end

defmodule Newnix.Subscribers do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Newnix.Repo
  alias Newnix.Projects.Project
  alias Newnix.Subscribers.Subscriber

  @doc """
  Returns the list of subscribers.

  ## Examples

      iex> list_subscribers()
      [%Menu{}, ...]

  """
  def list_subscribers(project = %Project{}) do
    project
    |> Repo.preload(:subscribers)
    |> then(fn p -> p.subscribers end)
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

  @doc """
  Creates a subscriber.

  ## Examples

      iex> create_subscriber(user, %{field: value})
      {:ok, %Subscriber{}}

      iex> create_subscriber(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscriber(project = %Project{}, attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Subscriber.project_assoc(project)
    |> Repo.insert()
  end

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
end

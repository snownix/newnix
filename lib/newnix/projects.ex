defmodule Newnix.Projects do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Newnix.Repo
  alias Newnix.Projects.Project
  alias Newnix.Accounts.User

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Menu{}, ...]

  """
  def list_projects(user = %User{}) do
    user
    |> Repo.preload(:projects)
    |> then(fn u -> u.projects end)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  def get_project!(user = %User{}, id) do
    Repo.one!(
      from p in Project,
        join: u in assoc(p, :users),
        where: p.id == ^id and u.id == ^user.id
    )
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(user, %{field: value})
      {:ok, %Project{}}

      iex> create_project(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(user = %User{}, attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Project.user_assoc(user)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end

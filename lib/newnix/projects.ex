defmodule Newnix.Projects do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias Newnix.Repo
  alias Newnix.Accounts.User
  alias Newnix.Projects.Invite
  alias Newnix.Projects.Project
  alias Newnix.Projects.UserProject

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
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Menu{}, ...]

  """
  def list_projects(user = %User{}) do
    user
    |> Repo.preload(
      projects:
        from(
          a in Project,
          order_by: [desc: a.inserted_at]
        )
    )
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
        where: p.id == ^id and u.id == ^user.id,
        preload: [:role]
    )
  end

  @doc """
  preload project users.

  ## Examples

      iex> list_users(project)
      %Project{ users: [] }

  """
  def list_users(%Project{} = project, opts \\ []) do
    Repo.preload(project, :users, opts)
  end

  @doc """
  list invites by user or projects.

  ## Examples

      iex> list_invites(%Projet{})
      %Project{ invites: [%Invite{}, ...] }

      iex> list_invites(%User{})
      [%Invite{}, ...]

  """
  def list_invites(%User{email: email, id: id} = _user) do
    query =
      from(
        i in Invite,
        where: i.email == ^email or i.user_id == ^id,
        preload: [:project]
      )

    Repo.all(query)
  end

  def list_invites(%Project{} = project, opts \\ []) do
    Repo.preload(project, :invites, opts)
  end

  @doc """
  Count user invites.

  ## Examples

      iex> count_invites(%User{})
      5

  """
  def count_invites(%User{email: email, id: id} = _user) do
    query =
      from(
        i in Invite,
        where: (i.email == ^email or i.user_id == ^id) and i.status == :pending,
        select: fragment("count(*)")
      )

    Repo.one!(query)
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

  @doc """
  Gets a single invite.

  Raises `Ecto.NoResultsError` if the invite does not exist.

  ## Examples

      iex> get_invite!(project, 123)
      %invite{}

      iex> get_invite!(project, 456)
      ** (Ecto.NoResultsError)

  """
  def get_invite!(%Project{id: id}, id) do
    query =
      from c in Invite,
        where: c.id == ^id and c.project_id == ^id

    Repo.one!(query)
  end

  def get_invite!(%User{email: email}, id) do
    query =
      from c in Invite,
        where: c.id == ^id and c.email == ^email

    Repo.one!(query)
  end

  @doc """
  Creates a invite.

  ## Examples

      iex> create_invite(project, sender, %{field: value})
      {:ok, %Invite{}}

      iex> create_invite(project, sender, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite(project = %Project{}, sender = %User{}, attrs \\ %{}) do
    %Invite{}
    |> Invite.changeset(attrs)
    |> Invite.project_assoc(project)
    |> Invite.sender_assoc(sender)
    |> Repo.insert()
    |> notify_subscribers([:invite, :created])
  end

  @doc """
  Updates a invite.

  ## Examples

      iex> update_invite(invite, %{field: new_value})
      {:ok, %Invite{}}

      iex> update_invite(invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite(%Invite{} = invite, attrs) do
    invite
    |> Invite.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:invite, :updated])
  end

  @doc """
  User Answer invite.

  ## Examples

      iex> answer_invite(invite, %{field: new_value})
      {:ok, %Invite{}}

      iex> answer_invite(invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def answer_invite(user = %User{}, %Invite{} = invite, answer) do
    invite =
      invite
      |> Repo.preload(:user)
      |> Repo.preload(:project)

    changeset =
      Invite.answer(invite, answer)
      |> Invite.user_assoc(user)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:invite, changeset)
    |> Ecto.Multi.insert(:user_project, fn _ ->
      %UserProject{}
      |> UserProject.user_assoc(user)
      |> UserProject.project_assoc(invite.project)
      |> UserProject.changeset(%{
        "role" => invite.role,
        "status" => :active
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{invite: invite}} ->
        {:ok, invite} |> notify_subscribers([:invite, :answer, answer])

      others ->
        others
    end
  end

  @doc """
  Deletes a invite.

  ## Examples

      iex> delete_invite(invite)
      {:ok, %Invite{}}

      iex> delete_invite(invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite(%Invite{} = invite) do
    Repo.delete(invite)
    |> notify_subscribers([:invite, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invite changes.

  ## Examples

      iex> change_invite(invite)
      %Ecto.Changeset{data: %Invite{}}

  """
  def change_invite(%Invite{} = invite, attrs \\ %{}) do
    Invite.changeset(invite, attrs)
  end
end

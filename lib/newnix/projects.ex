defmodule Newnix.Projects do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias Newnix.Repo
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Accounts.User
  alias Newnix.Builder.Form
  alias Newnix.Projects.Invite
  alias Newnix.Projects.Project
  alias Newnix.Projects.UserProject
  alias Newnix.Projects.ProjectToken
  alias Newnix.Projects.ProjectNotifier
  alias Newnix.Projects.Integration

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
    from(
      p in Project,
      join: u in assoc(p, :users),
      where: u.id == ^user.id and is_nil(p.deleted_at),
      order_by: {:desc, p.inserted_at}
    )
    |> Repo.all()
  end

  def meta_list_projects(user = %User{}) do
    from(
      p in Project,
      join: u in assoc(p, :users),
      where: u.id == ^user.id and is_nil(p.deleted_at),
      select: [:id, :name],
      order_by: {:desc, p.inserted_at}
    )
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!("xxxxx-xxxx-xxxx-xxxxx")
      %Project{}

      iex> get_project!("xxxxx-xxxx-xxxx-xxxxx")
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  def get_project!(user = %User{}, id) do
    Repo.one!(
      from p in Project,
        join: u in assoc(p, :users),
        where: p.id == ^id and u.id == ^user.id and is_nil(p.deleted_at),
        preload: [
          role:
            ^from(
              up in UserProject,
              where:
                up.user_id == ^user.id and
                  up.project_id == ^id
            )
        ]
    )
  end

  @doc """
  preload project users.

  ## Examples

      iex> list_users(project)
      %Project{ users: [] }

  """
  def list_users(%Project{} = project, opts \\ []) do
    preload_users_role =
      from u in User,
        join: up in UserProject,
        on: up.project_id == ^project.id and up.user_id == u.id,
        preload: [role: up]

    Repo.preload(project, [users: preload_users_role], opts)
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
        join: p in assoc(i, :project),
        where: is_nil(p.deleted_at) and (i.email == ^email or i.user_id == ^id),
        preload: [project: p]
      )

    Repo.all(query)
  end

  @doc """
  list integrations .

  ## Examples

      iex> list_integrations(%Projet{})
      [%{}, %{}]

      iex> list_integrations(%User{})
      [%Invite{}, ...]

  """
  def list_integrations(%Project{id: id} = _projecct) do
    query =
      from(
        i in Integration,
        join: p in assoc(i, :project),
        where: p.id == ^id
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
  Count project forms.

  ## Examples

      iex> count_forms(%User{})
      5

  """
  def count_forms(%Project{id: id}) do
    query =
      from(
        r in Form,
        where: r.project_id == ^id,
        select: fragment("count(*)")
      )

    Repo.one!(query)
  end

  @doc """
  Count project subscribers.

  ## Examples

      iex> count_subscribers(%User{})
      5

  """
  def count_subscribers(%Project{id: id}) do
    query =
      from(
        r in Subscriber,
        where: r.project_id == ^id,
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
    |> Project.user_assoc(user, :owner)
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
  Archive a project.

  ## Examples

      iex> safe_delete_project(project)
      {:ok, %Project{}}

      iex> safe_delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def safe_delete_project(%Project{} = project) do
    project
    |> Project.safe_delete_changeset()
    |> Repo.update()
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
  Gets a single user project.

  Raises `Ecto.NoResultsError` if the invite does not exist.

  ## Examples

      iex> get_project_user!(project, "xxxxx-xxxx-xxxx-xxxxx")
      %invite{}

      iex> get_project_user!(project, "xxxxx-xxxx-xxxx-xxxxx")
      ** (Ecto.NoResultsError)

  """
  def get_project_user!(%Project{id: project_id}, id) do
    query =
      from up in UserProject,
        where: up.project_id == ^project_id and up.user_id == ^id,
        preload: [:user, :project]

    Repo.one!(query)
  end

  @doc """
  Gets a single invite.

  Raises `Ecto.NoResultsError` if the invite does not exist.

  ## Examples

      iex> get_invite!(project, "xxxxx-xxxx-xxxx-xxxxx")
      %invite{}

      iex> get_invite!(project, "xxxxx-xxxx-xxxx-xxxxx")
      ** (Ecto.NoResultsError)

  """
  def get_invite!(%Project{id: project_id}, id) do
    query =
      from c in Invite,
        where: c.id == ^id and c.project_id == ^project_id

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

    multitr =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:invite, changeset)

    if answer == :accepted do
      multitr
      |> Ecto.Multi.insert(:user_project, fn _ ->
        %UserProject{}
        |> UserProject.user_assoc(user)
        |> UserProject.project_assoc(invite.project)
        |> UserProject.changeset(%{
          "role" => invite.role,
          "status" => :active
        })
      end)
    else
      multitr
    end
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

  @doc """
  Updates a project user.

  ## Examples

      iex> update_project_user(project_user, %{field: new_value})
      {:ok, %UserProject{}}

      iex> update_project_user(project_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_user(%UserProject{} = project_user, attrs) do
    project_user
    |> UserProject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a project user.

  ## Examples

      iex> delete_project_user(project_user)
      {:ok, %UserProject{}}

      iex> delete_project_user(bad_project_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_user(%UserProject{} = project_user) do
    project_user
    |> Repo.delete()
  end

  @doc """

  ## Examples

      iex> change_user(user_project)
      %Ecto.Changeset{data: %UserProject{}}

  """
  def change_user(%UserProject{} = user_project, attrs \\ %{}) do
    UserProject.changeset(user_project, attrs)
  end

  @doc """
  Gets the project by confirm project token.

  ## Examples

      iex> get_project_by_confirm_project_token("validtoken")
      %Project{}

      iex> get_project_by_confirm_project_token("invalidtoken")
      nil

  """
  def get_project_by_confirm_project_token(user, token) do
    with {:ok, query} <- ProjectToken.verify_email_token_query(user, token, "delete-confirm"),
         %Project{} = project <- Repo.one(query) do
      {:ok, project}
    else
      _ -> {:error, :invalid_token}
    end
  end

  @doc """
  Delivers the confirmation email instructions to the given project user.

  ## Examples

      iex> deliver_delete_confirmation(project, user, &Routes.project_confirmation_url(conn, :update, &1), client_agent)
      {:ok, %{to: ..., body: ...}}

      iex> deliver_delete_confirmation(confirmed_project, &Routes.project_confirmation_url(conn, :update, &1), client_agent)
      {:error, :already_deleted}

  """
  def deliver_delete_confirmation(
        %Project{} = project,
        %User{} = user,
        confirmation_url_fun,
        client_agent
      )
      when is_function(confirmation_url_fun, 1) do
    if project.deleted_at do
      {:error, :already_deleted}
    else
      {encoded_token, project_token} =
        ProjectToken.build_email_token(project, user, "delete-confirm")

      Repo.insert!(project_token)

      ProjectNotifier.deliver_delete_confirmation(
        project,
        user,
        confirmation_url_fun.(encoded_token),
        client_agent
      )
    end
  end

  @doc """
  Delivers the invite email instructions .

  ## Examples

      iex> delivery_invite_instructions(assigns, &Routes.project_confirmation_url(conn, :update, &1))
      {:ok, %{to: ..., body: ...}}

      iex> delivery_invite_instructions(assigns, &Routes.project_confirmation_url(conn, :update, &1))
      {:error, :already_deleted}

  """
  def delivery_invite_instructions(
        %{
          invite: invite
        } = assigns,
        confirmation_url
      ) do
    ProjectNotifier.delivery_invite_instructions(
      assigns,
      "#{confirmation_url}?invite=#{invite.id}"
    )
  end

  @doc """

  ## Examples

      iex> change_integration(integration)
      %Ecto.Changeset{data: %Integration{}}

  """
  def change_integration(%Integration{} = integration, attrs \\ %{}) do
    Integration.changeset(integration, attrs)
  end

  @doc """
  Gets a single integration.

  Raises `Ecto.NoResultsError` if the integration does not exist.

  ## Examples

      iex> get_integration!(project, "xxxxx-xxxx-xxxx-xxxxx")
      %integration{}

      iex> get_integration!(project, "xxxxx-xxxx-xxxx-xxxxx")
      ** (Ecto.NoResultsError)

  """
  def get_integration!(%Project{id: project_id}, id) do
    query =
      from c in Integration,
        where: c.id == ^id and c.project_id == ^project_id

    Repo.one!(query)
  end

  @doc """
  Creates a integration.

  ## Examples

      iex> create_integration(project, sender, %{field: value})
      {:ok, %Integration{}}

      iex> create_integration(project, sender, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_integration(project = %Project{}, user = %User{}, attrs \\ %{}) do
    %Integration{}
    |> Integration.changeset(attrs)
    |> Integration.project_assoc(project)
    |> Integration.user_assoc(user)
    |> Repo.insert()
    |> notify_subscribers([:integration, :created])
  end

  @doc """
  Updates a integration.

  ## Examples

      iex> update_integration(integration, %{field: new_value})
      {:ok, %Integration{}}

      iex> update_integration(integration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_integration(%Integration{} = integration, attrs) do
    integration
    |> Integration.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:integration, :updated])
  end

  @doc """
  Deletes a integration.

  ## Examples

      iex> delete_integration(integration)
      {:ok, %Integration{}}

      iex> delete_integration(integration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_integration(%Integration{} = integration) do
    Repo.delete(integration)
    |> notify_subscribers([:integration, :deleted])
  end
end

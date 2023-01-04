defmodule NewnixWeb.Live.Project.SettingsLive.Index do
  @doc false

  use NewnixWeb, :live_project

  alias Newnix.Projects
  alias Newnix.Projects.Invite

  def mount(_session, _params, socket) do
    %{assigns: %{project: project} = assigns} = socket = fetch_records(socket)

    if connected?(socket), do: Projects.subscribe(project.id)

    can_mount!(socket, :project, :settings, fn socket ->
      stats = %{
        campaigns: Enum.count(assigns[:project_campaigns]),
        members: Enum.count(project.users),
        forms: Projects.count_forms(project),
        subscribers: Projects.count_subscribers(project)
      }

      socket
      |> assign(:client_agent, parse_client_agent(get_connect_params(socket)))
      |> assign(project: project)
      |> assign(stats: stats)
      |> assign(changeset: Projects.change_project(project))
    end)
  end

  def handle_info({Projects, [_name, _event], _result}, socket) do
    {:noreply, socket |> fetch_records()}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :invite, _params) do
    socket
    |> assign(:invite, %Invite{})
    |> assign(:page_title, "New Invite")
  end

  defp apply_action(%{assigns: %{project: project}} = socket, :user, %{"id" => id}) do
    user_project = Projects.get_project_user!(project, id)

    socket
    |> assign(:user_project, user_project)
    |> assign(:page_title, "Edit User")
  end

  defp apply_action(socket, _, _) do
    socket
  end

  def handle_event("validate", %{"project" => params}, %{assigns: %{project: project}} = socket) do
    changeset =
      project
      |> Projects.change_project(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "save",
        %{"project" => project_params},
        %{assigns: %{project: project}} = socket
      ) do
    {:noreply,
     can_do!(socket, :project, :update, fn socket ->
       case Projects.update_project(project, project_params) do
         {:ok, project} ->
           socket
           |> assign(:project, project)
           |> put_flash(:success, "Project \"#{project.name}\" updated")

         {:error, %Ecto.Changeset{} = changeset} ->
           assign(socket, changeset: changeset)
       end
     end)}
  end

  def handle_event("delete-invite", %{"id" => id}, socket) do
    {:noreply,
     can_do!(socket, :invite, :delete, fn %{assigns: %{project: project}} = socket ->
       invite = Projects.get_invite!(project, id)
       {:ok, _} = Projects.delete_invite(invite)

       socket
     end)}
  end

  defp fetch_records(%{assigns: %{project: project}} = socket) do
    socket
    |> assign(
      :project,
      project
      |> Projects.list_users(force: true)
      |> Projects.list_invites(force: true)
    )
  end
end

defmodule NewnixWeb.Live.Project.SettingsLive.Delete do
  @doc false

  use NewnixWeb, :live_project

  alias Newnix.Projects

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(project_delete: nil)}
  end

  def handle_params(%{"token" => token}, _session, %{assigns: %{current_user: user}} = socket) do
    {:noreply,
     case Projects.get_project_by_confirm_project_token(user, token) do
       {:ok, project} ->
         socket |> assign(project: project)

       _ ->
         socket |> put_flash(:error, "Project not found") |> redirect(to: "/")
     end}
  end

  def handle_event("confirm", _params, socket) do
    {:noreply,
     can_do!(socket, :project, :delete, fn %{assigns: %{project: project}} = socket ->
       case Projects.safe_delete_project(project) do
         {:ok, _update} ->
           socket
           |> put_flash(
             :info,
             gettext(
               "Project successfully deleted. All data will be deleted within the next 15 days."
             )
           )
           |> redirect(to: Routes.project_path(socket, :leave))

         {:error, error} ->
           socket
           |> put_flash(:error, "Error in deleting project #{error}")
       end
     end)}
  end
end

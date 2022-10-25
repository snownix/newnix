defmodule NewnixWeb.Project.SettingsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Projects

  def mount(_session, _params, socket) do
    %{project: project} = socket.assigns

    {:ok, assign(socket, %{changeset: Projects.change_project(project)})}
  end

  def handle_event("validate", %{"project" => params}, %{assigns: assigns} = socket) do
    changeset =
      assigns.project
      |> Projects.change_project(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"project" => project_params}, %{assigns: assigns} = socket) do
    case Projects.update_project(assigns.project, project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> assign(:project, project)
         |> put_flash(:success, "Project \"#{project.name}\" updated")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

defmodule NewnixWeb.User.DashboardLive.New do
  use NewnixWeb, :live_user

  alias Newnix.Projects
  alias Newnix.Projects.Project

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initiale_assigns()}
  end

  def put_initiale_assigns(socket) do
    socket
    |> assign(changeset: Projects.change_project(%Project{}))
  end

  def handle_event("validate", %{"project" => params}, socket) do
    changeset =
      %Project{}
      |> Projects.change_project(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    %{current_user: current_user} = socket.assigns

    case Projects.create_project(current_user, project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created #{project.id}")
         |> redirect(to: Routes.live_path(socket, NewnixWeb.Project.DashboardLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket, changeset: changeset)
         |> put_changeset_errors(changeset)}
    end
  end
end

defmodule NewnixWeb.Live.Project.SettingsLive.User.FormComponent do
  use NewnixWeb, :live_component

  alias Newnix.Policies
  alias Newnix.Projects
  alias Newnix.Projects.UserProject

  def update(%{user_project: user_project} = assigns, socket) do
    changeset = Projects.change_user(user_project)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:roles, roles_list())
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"user_project" => params}, socket) do
    %{user_project: user_project} = socket.assigns

    changeset =
      user_project
      |> Projects.change_user(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user_project" => params}, socket) do
    %{user_project: user_project} = socket.assigns

    case Projects.update_project_user(user_project, params) do
      {:ok, _userproject} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end

    {:noreply, socket}
  end

  defp roles_list() do
    Policies.roles() |> Enum.map(&{&1, &1})
  end
end

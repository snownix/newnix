defmodule NewnixWeb.Project.SettingsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Projects

  def mount(_session, _params, socket) do
    %{project: project} = socket.assigns

    project = project |> Projects.list_users()

    {:ok,
     socket
     |> assign(project: project)
     |> assign(changeset: Projects.change_project(project))}
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

  attr :user, :map
  attr :logo, :string, default: nil

  def user_row(assigns) do
    ~H"""
      <tr>
        <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm sm:pl-6">
            <div class="flex items-center">
                <.ui_avatar text={"#{String.slice(@user.firstname,0,1)}#{String.slice(@user.lastname,0,1)}"} avatar={@user.avatar} />
                <div class="ml-4">
                    <div class="font-medium text-gray-900">
                        <%= @user.firstname %> <%= @user.lastname %>
                    </div>
                    <div class="text-gray-500">
                        <%= @user.email %>
                    </div>
                </div>
            </div>
        </td>
        <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500"><%= role(@user) %></td>
        <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500"><.date_added datetime={@user.inserted_at} /></td>
        <td :if={@admin} class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
            <a href="#" class="text-indigo-600 hover:text-indigo-900">
              Edit
            <span class="sr-only">, <%= @user.firstname %> <%= @user.lastname %></span>
            </a>
        </td>
    </tr>
    """
  end

  def role(%{admin: true}), do: "Admin"
  def role(%{admin: _}), do: "User"

  def date_added(assigns) do
    ~H"""
      <p>
        <%= Timex.format!(@datetime, "%d-%m-%y", :strftime) %>
      </p>
      <p class="text-xs text-grai">
        <%= Timex.from_now(@datetime) %>
      </p>
    """
  end
end

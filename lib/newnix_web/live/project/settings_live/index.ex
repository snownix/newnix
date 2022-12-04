defmodule NewnixWeb.Live.Project.SettingsLive.Index do
  @doc false

  use NewnixWeb, :live_project

  alias Newnix.Projects
  alias Newnix.Projects.Invite

  def mount(_session, _params, socket) do
    %{assigns: %{project: project}} = socket = fetch_records(socket)

    if connected?(socket), do: Projects.subscribe(project.id)

    {:ok,
     socket
     |> assign(project: project)
     |> assign(changeset: Projects.change_project(project))}
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

  attr :user, :map
  attr :role, :map, default: nil
  attr :logo, :string, default: nil

  def user_row(assigns) do
    ~H"""
      <tr>
        <td class="py-4 pl-4 pr-3 text-sm sm:pl-6">
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
        <td class="px-3 py-4 text-sm text-gray-500 capitalize">-</td>
        <td class="px-3 py-4 text-sm text-gray-500"><.date_added datetime={@user.inserted_at} /></td>
        <td>
          <div class="flex justify-center items-center">
            <.link :if={can?(@role, :invite, :update)} class="text-indigo-600 hover:text-indigo-900">
              <.ui_icon icon="cog" />
            </.link>
          </div>
        </td>
    </tr>
    """
  end

  attr :invite, :map
  attr :role, :map, default: nil
  attr :logo, :string, default: nil

  def invite_row(assigns) do
    ~H"""
      <tr>
        <td class="py-4 pl-4 pr-3 text-sm sm:pl-6">
            <div class="flex items-center">
                <.ui_avatar text={"#{String.slice(@invite.email,0,2)}"}  />
                <div class="ml-4">
                    <div class="font-medium text-gray-900">
                      Invite
                    </div>
                    <div class="text-gray-500">
                        <%= @invite.email %>
                    </div>
                </div>
            </div>
        </td>
        <td class="px-3 py-4 text-sm text-gray-500 capitalize"><%= role(@invite.role) %></td>
        <td class="px-3 py-4 text-sm text-gray-500"><.date_added datetime={@invite.inserted_at} /></td>
        <td>
          <div class="flex justify-center items-center">
            <.link
              :if={can?(:invite, :delete, @role)}
              phx-click="delete-invite"
              phx-value-id={@invite.id}
              class="text-indigo-600 hover:text-indigo-900">
              <.ui_icon icon="trash" />
            </.link>
          </div>
        </td>
    </tr>
    """
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

  def role(%{role: role}), do: role
  def role(name), do: name

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

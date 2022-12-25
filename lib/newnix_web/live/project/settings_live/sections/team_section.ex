defmodule NewnixWeb.Live.Project.SettingsLive.Sections.TeamSection do
  use NewnixWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
     <section class="flex flex-1">
            <div class="hidden md:block w-1/3 md:pr-4">
                <b>Projet Members</b>
                <p>Manage team accounts permissions.</p>
            </div>
            <div class="flex-1">
                <div class="inline-block w-full py-2 align-middle">
                    <div class="shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
                        <table class="min-w-full divide-y divide-gray-300">
                            <thead class="bg-gray-50">
                            <tr>
                                <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">
                                    Information
                                </th>
                                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                                    Status
                                </th>
                                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                                    <div class="flex space-x-1">
                                        <span>Role</span>
                                        <.link patch={Routes.project_settings_index_path(@socket, :roles)}>
                                            <.ui_icon icon="question" />
                                        </.link>
                                    </div>
                                </th>
                                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                                    Date Added
                                </th>
                                <th :if={can?(@role, :invite, :create)} scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
                                    <div class="flex w-full justify-end">
                                        <.ui_button navigate={Routes.project_settings_index_path(@socket, :invite)} size="xs">
                                            <.ui_icon icon="plus" />
                                        </.ui_button>
                                    </div>
                                </th>
                            </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200 bg-white">
                                 <.user_row
                                    :for={user <- @project.users}
                                    user={user}
                                    role={@role}
                                    self={user.id == @current_user.id}
                                    link={Routes.project_settings_index_path(@socket, :user, user.id)} />
                                <.invite_row
                                    :for={invite <- @project.invites}
                                    role={@role}
                                    invite={invite}
                                    :if={invite.status != :accepted}/>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </section>
    """
  end

  attr :user, :map
  attr :role, :map, default: nil
  attr :self, :boolean, default: false
  attr :logo, :string, default: nil
  attr :link, :string, default: ""

  def user_row(assigns) do
    ~H"""
      <tr>
        <td class="py-4 pl-4 pr-3 text-sm sm:pl-6">
            <div class="flex items-center">
                <.ui_avatar
                  avatar={@user.avatar}
                  text={"#{String.slice(@user.firstname,0,1)}#{String.slice(@user.lastname,0,1)}"}/>
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
        <td class="px-3 py-4 text-sm text-gray-500 capitalize"><%= status(@user.role) %></td>
        <td class="px-3 py-4 text-sm text-gray-500 capitalize">
          <%= role(@user.role) %>
        </td>
        <td class="px-3 py-4 text-sm text-gray-500"><.date_added datetime={@user.inserted_at} /></td>
        <td>
          <div class="flex justify-center items-center">
            <.link
              :if={can?(@role, :invite, :update) and not @self}
              patch={@link}
              class="text-indigo-600 hover:text-indigo-900">
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
        <td class="px-3 py-4 text-sm text-gray-500 capitalize"><%= status(@invite) %></td>
        <td class="px-3 py-4 text-sm text-gray-500 capitalize"><%= role(@invite.role) %></td>
        <td class="px-3 py-4 text-sm text-gray-500"><.date_added datetime={@invite.inserted_at} /></td>
        <td>
          <div class="flex justify-center items-center">
            <.link
              :if={can?(@role, :invite, :delete)}
              phx-click="delete-invite"
              phx-value-id={@invite.id}
              data={[confirm: "Are you sure?" ]}
              class="text-indigo-600 hover:text-indigo-900">
              <.ui_icon icon="trash" />
            </.link>
          </div>
        </td>
    </tr>
    """
  end

  def role(%{role: role}), do: role
  def role(name), do: name

  def status(%{status: status}), do: status
  def status(_), do: "unknown"

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

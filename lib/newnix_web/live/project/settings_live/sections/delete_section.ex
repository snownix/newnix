defmodule NewnixWeb.Live.Project.SettingsLive.Sections.DeleteSection do
  use NewnixWeb, :live_component

  alias Newnix.Projects

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:actions, false)
     |> assign(:open_delete, false)
     |> assign(:valid_confirm, false)}
  end

  def render(assigns) do
    ~H"""
      <section class="flex flex-1 pt-8">
          <div class="hidden md:block w-1/3 md:pr-4">
            <b><%= gettext "Delete this project" %></b>
          </div>
          <div class="flex-1 space-y-6">
            <b class="text-lg">Delete this project</b>
            <p>This action deletes <code class="bg-gray-200 px-2 py-1 rounded text-sm"><%= @project.name %></code>
              on <%= Timex.today() %> and everything this project contains. There is no going back.</p>

            <div class="flex w-full justify-end">
              <.ui_button theme="danger" size="small" phx-click="toggle-delete" phx-target={@myself}>
                <.ui_icon icon="trash" />
                <span>Delete Project</span>
              </.ui_button>
            </div>
          </div>
          <.delete_modal
            :if={@open_delete}
            myself={@myself}
            actions={@actions}
            stats={@stats}
            project={@project}
            open_delete={@open_delete}
            valid_confirm={@valid_confirm}
            flash={@flash}
          />
      </section>
    """
  end

  def handle_event("toggle-delete", _, %{assigns: %{open_delete: open_delete}} = socket) do
    {:noreply, socket |> assign(:open_delete, !open_delete)}
  end

  def handle_event("validate-delete", %{"delete" => %{"project" => project_name}}, socket) do
    valid_confirm = project_name === socket.assigns.project.name

    socket =
      socket
      |> assign(:valid_confirm, valid_confirm)
      |> assign(:actions, valid_confirm)

    {:noreply,
     if valid_confirm do
       socket |> clear_flash()
     else
       socket |> put_flash(:error, "Please enter project name correctly!")
     end}
  end

  def handle_event(
        "confirm-delete",
        _,
        %{
          assigns: %{
            valid_confirm: valid_confirm,
            client_agent: client_agent,
            project: project,
            user: user
          }
        } = socket
      ) do
    socket = socket |> clear_flash()

    {:noreply,
     if valid_confirm do
       case Projects.deliver_delete_confirmation(
              project,
              user,
              &Routes.project_settings_delete_path(socket, :confirm, &1),
              client_agent
            ) do
         {:error, message} ->
           socket |> put_flash(:error, "Error #{message}")

         _ ->
           socket
           |> assign(:actions, false)
           |> put_flash(:info, "An email confirming the deletion has been sent to your inbox.")
       end
     else
       socket |> put_flash(:error, "Please enter project name correctly!")
     end}
  end

  attr :stats, :map, default: %{}
  attr :actions, :boolean
  attr :project, :map
  attr :open_delete, :boolean

  def delete_modal(assigns) do
    ~H"""
    <div data-modal-backdrop="static" tabindex="-1" aria-hidden="true" class="fixed top-0 left-0 right-0 z-50 w-full overflow-x-hidden overflow-y-auto md:inset-0 h-modal h-full">
        <div class="relative w-full h-full flex justify-center items-center">
          <div class="w-full h-full absolute inset-0 bg-gray-500 bg-opacity-50" phx-click="toggle-delete" phx-target={@myself}></div>
            <!-- Modal content -->
            <.form :let={f} for={:delete} phx-target={@myself} phx-change="validate-delete" phx-submit="confirm-delete"
            class="relative bg-white max-w-screen-sm h-max rounded-lg shadow dark:bg-gray-700 overflow-hidden">
                <!-- Modal header -->
                <div class="flex items-start justify-between p-4 border-b rounded-t dark:border-gray-600">
                    <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                        Are you absolutely sure?
                    </h3>
                    <button
                      phx-click="toggle-delete" phx-target={@myself}
                      type="button"
                      class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-600 dark:hover:text-white">
                        <.ui_icon icon="close" />
                    </button>
                </div>
                <!-- Modal body -->
                <div class="p-6 space-y-6">
                    <.ui_alert theme="error" class="space-y-2">
                      <div class="flex-center font-semibold text-base">
                        <span><%= gettext "You are about to delete this project containing" %></span>
                      </div>
                      <ul class="mt-2 pl-6 list-disc">
                        <li>
                          <b><%= @stats[:subscribers] || 0 %></b>
                          <%= gettext "Subscribers" %>
                        </li>
                        <li>
                          <b><%= @stats[:campaigns] || 0 %></b>
                          <%= gettext "Campaigns" %>
                        </li>
                        <li>
                          <b><%= @stats[:forms] || 0 %></b>
                          <%= gettext "Forms" %>
                        </li>
                        <li>
                          <b><%= @stats[:members] || 0 %></b>
                          <%= gettext "Members" %>
                        </li>
                      </ul>
                    </.ui_alert>
                    <.ui_alert theme="error" class="flex-center font-medium">
                      <.ui_icon icon="alert" />
                      <p><%= gettext "This process deletes the project and all associated resources" %></p>
                    </.ui_alert>
                    <div :if={!@valid_confirm} class="flex flex-col space-y-2">
                      <p>Enter the following to confirm:</p>
                      <code class="bg-gray-200 px-2 py-1 rounded text-sm"><%= @project.name %></code>
                      <p><%= input_value(f, :project) %></p>
                      <.ui_basic_input form={f} name={:project} title="Project name" />
                    </div>
                </div>
                <.live_component module={NewnixWeb.Live.Components.AlertsComponent} close={false} flash={@flash} id="alerts-delete" />

                <!-- Modal footer -->
                <div :if={@actions} class="flex items-center justify-between p-6 space-x-2 border-t border-gray-200 rounded-b dark:border-gray-600">
                    <.ui_button type="button" theme="dark" size="small" phx-click="toggle-delete" phx-target={@myself}>
                      <.ui_icon icon="close" /> <span>Cancel</span>
                    </.ui_button>
                    <.ui_button type="submit" theme="danger" size="small">
                      <.ui_icon icon="trash" /> <span>Delete</span>
                    </.ui_button>
                </div>
            </.form>
        </div>
    </div>
    """
  end
end

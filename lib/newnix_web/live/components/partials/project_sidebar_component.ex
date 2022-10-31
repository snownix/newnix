defmodule NewnixWeb.Components.Partials.ProjectSidebarComponent do
  use NewnixWeb, :live_component

  attr :project, :map, default: nil
  attr :campaign, :map, default: nil
  attr :projects, :map, default: []
  attr :campaigns, :map, default: []
  attr :projects_open, :boolean, default: false

  def render(assigns) do
    ~H"""
      <nav
        aria-label="Sidebar"
        class="hidden md:flex"
      >
        <%= if @project do %>
          <div class="md:flex-shrink-0 dark:md:bg-dark-800 md:overflow-y-auto border-r w-72 bg-gray-50">
            <.project_logo target={@myself} project={@project} />

            <div class="px-4 py-3 space-y-8">
              <ul>
                <.menu_item link={Routes.live_path(@socket, NewnixWeb.Project.DashboardLive.Index)} icon="layers">
                  Dashboard
                </.menu_item>
                <.menu_item link={Routes.campaigns_index_path(@socket, :index)} icon="inbox">
                  Campaigns
                </.menu_item>
                <.menu_item link={Routes.subscribers_index_path(@socket, :index)} icon="user-group">
                  Subscribers
                </.menu_item>
                <.menu_item link={Routes.live_path(@socket, NewnixWeb.Project.SettingsLive.Index)} icon="settings">
                  Settings
                </.menu_item>
              </ul>

              <div class="px-3.5 space-y-2">
                <div class="text-sm font-medium text-gray-400">Campaigns</div>
                <ul class="space-y-1">
                 <li
                 :for={[id, name] <- @campaigns}
                 >
                 <.campaign_item
                    link={Routes.campaigns_show_path(@socket, :show, id)}
                    active={is_current_active(assigns, id)}
                    id={id}
                    >
                    <%= name %>
                  </.campaign_item>
                 </li>
                 <li>
                  <.campaign_item icon="plus" link={Routes.campaigns_index_path(@socket, :new)} class="text-gray-500">
                    New campaign
                  </.campaign_item>
                 </li>
                </ul>
              </div>
            </div>
          </div>
        <% end %>
      </nav>
    """
  end

  def handle_event("toggle-projects", _params, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(:projects_open, !assigns[:projects_open])}
  end

  slot(:inner_block)
  attr :icon, :string, default: ""

  def menu_item(assigns) do
    ~H"""
      <.link navigate={@link}
        class="w-full h-10 px-4 font-medium flex-shrink-0 inline-flex items-center text-dark-50 hover:text-primary-500 hover:bg-gray-100 dark:text-white rounded-md dark:bg-dark-900 space-x-4">
          <span>
            <.ui_icon class="w-6 h-6" icon={@icon}/>
          </span>
          <div>
            <%= render_slot(@inner_block) %>
          </div>
      </.link>
    """
  end

  attr :class, :string, default: ""
  attr :active, :boolean, default: false

  def campaign_item(assigns) do
    color = string_to_color_hash(assigns[:id] || "default")

    assigns = assign(assigns, :color, color)

    ~H"""
      <.link navigate={@link}
        class={"w-full py-1.5 px-2 font-medium flex-shrink-0 inline-flex items-center text-dark-50 hover:text-primary-500 hover:bg-gray-100 dark:text-white rounded-md dark:bg-dark-900 space-x-4 #{@active && "bg-primary-100" ||""} #{@class}"}>
          <%= if assigns[:icon] do %>
            <div class={"w-4 h-4 rounded flex-shrink-0 border flex items-center justify-center"}>
              <.ui_icon class="w-full h-full" icon={@icon} />
            </div>
          <% else %>
            <div class={"w-4 h-4 rounded flex-shrink-0"} style={"background-color: #{@color};"}></div>
          <% end %>
          <div class="truncate text-ellipsis">
            <%= render_slot(@inner_block) %>
          </div>
      </.link>
    """
  end

  def is_current_active(%{campaign: campaign} = _assigns, id) when not is_nil(campaign),
    do: id == campaign.id

  def is_current_active(_assigns, _id), do: false

  def project_logo(assigns) do
    ~H"""
      <div
        phx-click="toggle-projects" phx-target={@target}
        class="flex items-center space-x-4 py-4 px-6 flex-1 bg-white  border-b cursor-pointer">
        <div class="flex flex-col space-y-0.5 w-full">
          <span class="font-semibold truncate text-ellipsis text-gray-900">
            <%= @project.name %>
          </span>
          <span class="text-gray-500 text-sm">Team free</span>
        </div>
      </div>
    """
  end

  def project_avatar(name) do
    String.slice("#{name}", 0..1)
  end
end

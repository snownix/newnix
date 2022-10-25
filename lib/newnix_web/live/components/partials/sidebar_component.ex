defmodule NewnixWeb.Components.Partials.SidebarComponent do
  use NewnixWeb, :live_component

  attr :project, :map, default: nil
  attr :campaigns, :map, default: []
  attr :projects, :map, default: []
  attr :projects_open, :boolean, default: false

  def render(assigns) do
    ~H"""
      <nav
        aria-label="Sidebar"
        class="hidden md:flex flex-1"
      >
        <%= if @project do %>
          <div class="md:flex-shrink-0 dark:md:bg-dark-800 md:overflow-y-auto border-r w-72 bg-gray-50">
            <.project_logo target={@myself} project={@project} />

            <div class="px-4 py-3 space-y-8">
              <ul>
                <.menu_item link={Routes.live_path(@socket, NewnixWeb.Project.DashboardLive.Index)} icon="dashboard">Dashboard</.menu_item>
                <.menu_item link={Routes.live_path(@socket, NewnixWeb.Project.CampaignsLive.Index)} icon="campaign">Campaigns</.menu_item>
                <.menu_item link={Routes.live_path(@socket, NewnixWeb.Project.CampaignsLive.Index)} icon="users">Subscribers</.menu_item>
                <.menu_item link={Routes.live_path(@socket, NewnixWeb.Project.CampaignsLive.Index)} icon="settings">Settings</.menu_item>
              </ul>

              <div class="space-y-1">
                <div class="px-3.5 text-sm font-medium text-gray-400">Campaigns</div>
                <ul>
                  <.campaign_item :for={campaign <- @campaigns} campaign={campaign} index={0} link="#" />
                  <.campaign_item index={0} icon="plus" link="#" class="text-gray-500">new campaign</.campaign_item>
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

  def menu_item(assigns) do
    ~H"""
      <.link navigate={@link}
        class="w-full h-10 px-4 font-medium flex-shrink-0 inline-flex items-center text-dark-50 hover:text-primary-500 hover:bg-gray-100 dark:text-white rounded-md dark:bg-dark-900 space-x-4">
          <span>
            <%= NewnixWeb.IconsView.render @icon, %{class: "w-5 h-5"} %>
          </span>
          <div>
            <%= render_slot(@inner_block) %>
          </div>
      </.link>
    """
  end

  attr :campaign, :map
  attr :class, :string, default: ""

  def campaign_item(%{index: index} = assigns) do
    colors = ~w(bg-primary-400 bg-green-400 bg-red-400 bg-yellow-400 bg-purple-400 bg-orange-400)
    color = Enum.at(colors, rem(index, Enum.count(colors)))

    ~H"""
      <a href={@link}
        class={"w-full py-1 px-4 font-medium flex-shrink-0 inline-flex items-center text-dark-50 hover:text-primary-500 hover:bg-gray-100 dark:text-white rounded-md dark:bg-dark-900 space-x-4 #{@class}"}>
          <%= if assigns[:icon] do %>
            <div class={"w-4 h-4 rounded border flex items-center justify-center"}>
            <%= NewnixWeb.IconsView.render @icon, %{class: "w-full h-full"} %>
            </div>
          <% else %>
            <div class={"w-4 h-4 rounded #{color}"}></div>
          <% end %>
          <div>
            <%= render_slot(@inner_block) %>
          </div>
      </a>
    """
  end

  def project_logo(assigns) do
    ~H"""
      <div
        phx-click="toggle-projects" phx-target={@target}
        class="flex items-center space-x-4 py-4 px-6 flex-1 bg-white  border-b cursor-pointer">
        <div class="flex flex-col space-y-0.5 w-full">
          <span class="font-semibold text-gray-900"><%= @project.name %></span>
          <span class="text-gray-500 text-sm">Team free</span>
        </div>
      </div>
    """
  end

  def project_avatar(name) do
    String.slice("#{name}", 0..1)
  end
end

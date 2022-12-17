defmodule NewnixWeb.Live.Components.Partials.ProjectSidebarComponent do
  use NewnixWeb, :live_component

  attr :user, :map, default: %{}
  attr :role, :map, default: %{}
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
          <div class="flex flex-col md:flex-shrink-0 dark:md:bg-dark-800 md:overflow-y-auto border-r w-72 bg-gray-50">
            <.project_header return_to={Routes.live_path(@socket, NewnixWeb.Live.Project.DashboardLive.Index)} target={@myself} project={@project} />

            <div class="flex-1 px-4 py-3 space-y-8">
              <ul>
                <.menu_item link={Routes.live_path(@socket, NewnixWeb.Live.Project.DashboardLive.Index)} icon="layers">
                  Dashboard
                </.menu_item>
                <.menu_item :if={can?(@role, :campaign, :list)} link={Routes.project_campaigns_index_path(@socket, :index)} icon="inbox-stack">
                  Campaigns
                </.menu_item>
                <.menu_item :if={can?(@role, :subscriber, :list)} link={Routes.project_subscribers_index_path(@socket, :index)} icon="user-group">
                  Subscribers
                </.menu_item>
                <.menu_item :if={can?(@role, :form, :list)} link={Routes.project_forms_index_path(@socket, :index)} icon="window">
                  Forms
                </.menu_item>
                <.menu_item :if={can?(@role, :project, :settings)} link={Routes.live_path(@socket, NewnixWeb.Live.Project.SettingsLive.Index)} icon="settings">
                  Settings
                </.menu_item>
              </ul>

              <div class="px-3.5 space-y-2">
                <div class="text-sm font-medium text-gray-400">Campaigns</div>
                <ul class="space-y-1">
                 <li
                 :for={campaign<- @campaigns}
                 >
                 <.campaign_item
                    link={Routes.project_campaigns_show_path(@socket, :show, campaign.id)}
                    active={is_current_active(assigns, campaign.id)}
                    id={campaign.id}
                    >
                    <%= campaign.name %>
                  </.campaign_item>
                 </li>
                 <li>
                  <.campaign_item icon="plus" link={Routes.project_campaigns_index_path(@socket, :create)} class="text-gray-500">
                    New campaign
                  </.campaign_item>
                 </li>
                </ul>
              </div>
            </div>
            <.user_account role={@role} user={@user} />
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
      <.link patch={@link}
        class={"w-full py-1.5 px-2 font-medium flex-shrink-0 inline-flex items-center text-dark-50 hover:text-primary-500 hover:bg-gray-100 dark:text-white rounded-md dark:bg-dark-900 space-x-4 #{@active && "bg-primary-100" ||""} #{@class}"}>
          <%= if assigns[:icon] do %>
            <div class={"w-4 h-4 rounded flex-shrink-0 border flex items-center justify-center"}>
              <.ui_icon class="w-full h-full" icon={@icon} />
            </div>
          <% else %>
            <.ui_square_color color={@color} />
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

  attr :return_to, :string

  def project_header(assigns) do
    ~H"""
      <.link patch={@return_to}
        class="flex-grow-0 py-4 px-6 flex-1 bg-white  border-b cursor-pointer">
        <div class="flex flex-col space-y-0.5 w-full">
          <span class="font-semibold truncate text-ellipsis text-gray-900">
            <%= @project.name %>
          </span>
          <span class="text-gray-500 text-sm">Free plan</span>
        </div>
      </.link>
    """
  end

  attr :role, :map, required: true
  attr :user, :map, required: true

  def user_account(assigns) do
    ~H"""
      <div
        class="flex-grow-0 py-4 px-6 bg-white border-t">
        <div class="flex flex-col space-y-0.5  w-full">
          <div class="flex justify-between">
            <span class="font-semibold truncate text-ellipsis text-gray-900">
              <%= @user.firstname %>
            </span>
            <span class="font-normal text-gray-500">
              <%= @role.role %>
            </span>
          </div>
          <span class="text-gray-500 text-sm"><%= @user.email %></span>
        </div>
      </div>
    """
  end

  def project_avatar(name) do
    String.slice("#{name}", 0..1)
  end
end

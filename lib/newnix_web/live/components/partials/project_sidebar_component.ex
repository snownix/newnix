defmodule NewnixWeb.Live.Components.Partials.ProjectSidebarComponent do
  use NewnixWeb, :live_component

  attr :user, :map, default: %{}
  attr :role, :map, default: %{}
  attr :project, :map, default: nil
  attr :campaign, :map, default: nil
  attr :target, :string, default: nil
  attr :projects, :map, default: []
  attr :campaigns, :map, default: []

  def render(assigns) do
    ~H"""
      <nav
        aria-label="Sidebar"
        class="hidden md:flex"
      >
        <%= if @project do %>
          <div class="flex flex-col md:flex-shrink-0 md:overflow-y-auto border-r w-72 bg-gray-50">
            <.project_header target={@target} project={@project} />

            <div class="sidebar__menu">
              <ul>
                <.menu_item
                  link={Routes.project_dashboard_index_path(@socket, :index)} icon="layers">
                  Dashboard
                </.menu_item>
                <.menu_item
                  :if={can?(@role, :campaign, :access)}
                  link={Routes.project_campaigns_index_path(@socket, :index)} icon="inbox-stack">
                  Campaigns
                </.menu_item>
                <.menu_item
                  :if={can?(@role, :subscriber, :access)}
                  link={Routes.project_subscribers_index_path(@socket, :index)} icon="user-group">
                  Subscribers
                </.menu_item>
                <.menu_item
                  :if={can?(@role, :form, :access)}
                  link={Routes.project_forms_index_path(@socket, :index)} icon="window">
                  Forms
                </.menu_item>
                <.menu_item
                  :if={can?(@role, :workflows, :access)}
                  link={Routes.project_workflows_index_path(@socket, :index)} icon="chip">
                  Workflows
                </.menu_item>
                <.menu_item
                  :if={can?(@role, :template, :access)}
                  link={Routes.project_templates_index_path(@socket, :index)} icon="brush">
                  Templates
                </.menu_item>
                  <.menu_item
                    :if={can?(@role, :integration, :access)}
                    link={Routes.project_integrations_index_path(@socket, :index)} icon="puzzle">
                    Integrations
                  </.menu_item>
                  <.menu_item
                    :if={can?(@role, :project, :settings)}
                    link={Routes.project_settings_index_path(@socket, :index)} icon="settings">
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
                  <.campaign_item class="menu__item" icon="plus" link={Routes.project_campaigns_index_path(@socket, :create)} class="text-gray-500">
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

  slot(:inner_block)
  attr :icon, :string, default: ""
  attr :active, :boolean, default: false

  def menu_item(assigns) do
    ~H"""
      <.link navigate={@link}
        data-link={@link}
        class={"menu__item"}>
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
        data-link={@link}
        class={"w-full py-1.5 px-2 font-medium flex-shrink-0 inline-flex items-center text-dark-50 rounded-md  space-x-4 #{@active && "bg-gray-200" ||""} #{@class}"}>
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

  attr :target, :string
  attr :project, :map

  def project_header(assigns) do
    ~H"""
      <div
        class="flex justify-between items-center flex-grow-0 py-4 px-6 flex-1 bg-white  border-b cursor-pointer space-x-4">
          <.project_button
            phx-click="toggle-sidebar" phx-target={@target}
            active={false}
            project={@project} />
          <div class="flex flex-col w-full">
            <span class="font-semibold truncate text-ellipsis text-gray-900">
              <%= @project.name %>
            </span>
            <span class="text-gray-500 text-sm">Free plan</span>
          </div>
      </div>
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
            <span class="capitalize font-normal text-gray-500">
              <%= @role.role %>
            </span>
          </div>
          <span class="text-gray-500 text-sm"><%= @user.email %></span>
        </div>
      </div>
    """
  end

  attr :rest, :global, include: ~w(phx-click phx-target)
  attr :active, :boolean, default: false
  attr :project, :map

  def project_button(assigns) do
    ~H"""
      <.menu_button {@rest} active={@active}>
        <span>
          <%= project_logo(@project) %>
        </span>
      </.menu_button>
    """
  end

  slot(:inner_block)
  attr :link, :string
  attr :class, :string, default: nil
  attr :active, :boolean, default: false
  attr :rest, :global, include: ~w(phx-click phx-target)

  def menu_button(assigns) do
    ~H"""
      <div
        {@rest}
        class={"w-full w-12 h-12 flex-shrink-0 flex bg-gray-100 justify-center items-center  font-medium hover:text-white hover:bg-primary-500 rounded-md space-x-4 #{@class} " <> (if @active, do: "bg-primary-500 text-white", else: "text-gray-500")}>
          <span><%= render_slot(@inner_block) %></span>
      </div>
    """
  end

  attr :name, :string
  attr :logo, :string

  def project_logo(assigns) do
    ~H"""
      <div class="w-8 h-8 flex items-center justify-center text-lg font-bold uppercase">
        <%= if @logo do %>
          <img src={@logo} />
        <% else %>
          <span><%= project_name(@name) %></span>
        <% end %>
      </div>
    """
  end

  defp project_name(name), do: String.slice(name, 0, 2)
end

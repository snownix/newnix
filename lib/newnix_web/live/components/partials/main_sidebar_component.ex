defmodule NewnixWeb.Live.Components.Partials.MainSidebarComponent do
  use NewnixWeb, :live_component

  attr :project, :map
  attr :projects, :map, default: []
  attr :campaigns, :map, default: []
  attr :projects_open, :boolean, default: false

  def render(assigns) do
    ~H"""
      <nav
        aria-label="Sidebar"
        class="hidden md:flex w-20 flex-col md:flex-shrink-0 dark:md:bg-dark-800 md:overflow-y-auto border-r space-y-4 py-4"
      >

        <div class="px-4 flex-1">
          <ul class="space-y-3">
            <.project_button :for={project <- @projects} link={Routes.project_path(@socket, :open, project)} project={project} active={active(assigns[:project], project)} />
            <.project_add_button />
          </ul>
        </div>

        <div class="px-4 mt-auto">
          <ul class="space-y-3">
           <.auth_logout />
          </ul>
        </div>
      </nav>
    """
  end

  def active(nil, _project), do: false
  def active(project, current_project), do: project.id == current_project.id

  def handle_event("toggle-projects", _params, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(:projects_open, !assigns[:projects_open])}
  end

  def logo(assigns) do
    ~H"""
      <.link navigate={"/"} class="flex items-center justify-center py-8 text-white h-20">
        <.ui_icon class="w-12 h-12 text-primary-500" icon="logo"/>
      </.link>
    """
  end

  attr :project, :map
  attr :active, :boolean, default: false

  def project_button(assigns) do
    ~H"""
      <.menu_button link={@link} active={@active}>
          <span>
            <%= project_logo(@project) %>
          </span>
      </.menu_button>
    """
  end

  def project_add_button(assigns) do
    ~H"""
      <.menu_button link={"/new"}>
        <.ui_icon class="w-6 h-6" icon="plus"/>
      </.menu_button>
    """
  end

  slot(:inner_block)
  attr :link, :string
  attr :active, :boolean, default: false

  def menu_button(assigns) do
    ~H"""
      <.link navigate={@link}
        class={"w-full h-12 flex-shrink-0 flex bg-gray-50 justify-center items-center  font-medium hover:text-white hover:bg-primary-500 dark:text-white rounded-md dark:bg-dark-900 space-x-4 " <> (if @active, do: "bg-primary-500 text-white", else: "text-gray-500")}>
          <%= render_slot(@inner_block) %>
      </.link>
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

  def auth_logout(assigns) do
    ~H"""
      <.link href="/auth/logout" method="delete" class="w-full h-12 flex-shrink-0 flex bg-gray-50 justify-center items-center text-dark-50 font-medium hover:text-primary-500 hover:bg-gray-100 dark:text-white rounded-md dark:bg-dark-900 space-x-4">
        <.ui_icon class="w-6 h-6" icon="logout"/>
      </.link>
    """
  end
end

defmodule NewnixWeb.Live.Components.Partials.SidebarsComponent do
  use NewnixWeb, :live_component

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:sidebar_open, assigns[:sidebar_open])}
  end

  attr :user, :map, default: %{}
  attr :role, :map, default: %{}
  attr :project, :map, default: nil
  attr :sidebar, :atom, default: :user
  attr :count_invites, :integer, default: 0
  attr :current_user, :map, default: nil
  attr :campaign, :map, default: nil
  attr :projects, :map, default: []
  attr :campaigns, :map, default: []
  attr :project_campaigns, :map, default: []
  attr :projects_open, :boolean, default: false

  def render(assigns) do
    ~H"""
      <section class="h-full flex">
       <.live_component
        id="user-sidebar"
        :if={@sidebar_open}
        sidebar={@sidebar}
        project={@project}
        projects={@projects}
        count_invites={@count_invites}
        module={NewnixWeb.Live.Components.Partials.MainSidebarComponent}
        />
       <.live_component
          id="project-sidebar"
          role={@role}
          user={@current_user}
          sidebar={@sidebar}
          project={@project}
          campaign={assigns[:campaign]}
          projects={@projects}
          campaigns={@project_campaigns}
          target={@myself}
          module={NewnixWeb.Live.Components.Partials.ProjectSidebarComponent}
          />
      </section>
    """
  end

  def handle_event("toggle-sidebar", _params, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(:sidebar_open, !assigns.sidebar_open)}
  end
end

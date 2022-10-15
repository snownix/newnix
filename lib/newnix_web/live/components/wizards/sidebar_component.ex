defmodule NewnixWeb.Components.Wizards.SidebarComponent do
  use NewnixWeb, :live_component

  def render(assigns) do
    ~H"""
      <nav
        aria-label="Sidebar"
        class="hidden md:block md:flex-shrink-0 dark:md:bg-dark-800 md:overflow-y-auto border-r"
      >
        <div class="w-96 flex flex-col py-3 space-y-2">
        <%= if @sidebar === :user do %>
          <.menu_item link="#" icon="dashboard">Home</.menu_item>
          <.menu_item link="#" icon="kanban">Home</.menu_item>
          <.menu_item link="#" icon="users">Home</.menu_item>
        <% else %>
          <.menu_item link={Routes.index_path(@socket,:project)} icon="kanban">Dashboard</.menu_item>
          <.menu_item link={Routes.index_path(@socket,:project)} icon="bullseye">Campaigns</.menu_item>
          <.menu_item link={Routes.index_path(@socket,:project)} icon="person-lines-fill">Subsribers</.menu_item>
        <% end %>
        </div>
      </nav>
    """
  end

  def menu_item(assigns) do
    ~H"""
    <a href={@link}
      class="">
        <div class="">
          <%= render_slot(@inner_block) %>
        </div>
        <span class="">
          <%= NewnixWeb.IconsView.render @icon, %{class: "w-6 h-6"} %>
        </span>
    </a>
    """
  end
end

defmodule NewnixWeb.Components.Partials.SidebarComponent do
  use NewnixWeb, :live_component

  def render(assigns) do
    ~H"""
      <nav
        aria-label="Sidebar"
        class="hidden md:block md:flex-shrink-0 dark:md:bg-dark-800 md:overflow-y-auto border-r"
      >
        <div
          class="logo__ w-12 h-12 bg-dark-900 bg-opacity-5 text-xl text-dark-100 rounded-full flex items-center justify-center m-auto mt-4"></div>

        <div class="w-20 flex flex-col py-3 space-y-2">
        <%= if @sidebar === :user do %>
          <.menu_item link="#" icon="dashboard">Home</.menu_item>
          <.menu_item link="#" icon="kanban">Home</.menu_item>
          <.menu_item link="#" icon="users">Home</.menu_item>
        <% else %>
          <.menu_item link={Routes.index_path(@socket,:project)} icon="kanban">Dashboard</.menu_item>
          <.menu_item link={Routes.index_path(@socket,:project)} icon="bullseye">Campaigns</.menu_item>
          <.menu_item link={Routes.index_path(@socket,:project)} icon="person-linesicon-fill">Subsribers</.menu_item>
        <% end %>
        </div>
      </nav>
    """
  end

  def menu_item(assigns) do
    ~H"""
    <a href={@link}
      class="
        menu_item__
        w-full h-16
        flex-shrink-0 inline-flex items-center justify-center
        text-dark-50 dark:text-white
        dark:bg-dark-900
        hover:text-primary-500
        ">
        <div class="menu_item_icon__ py-2 text-sm px-3 rounded bg-dark-200 text-white absolute z-50">
          <%= render_slot(@inner_block) %>
        </div>
        <span class="icon__">
          <%= NewnixWeb.IconsView.render @icon, %{class: "w-6 h-6"} %>
        </span>
    </a>
    """
  end
end

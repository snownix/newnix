defmodule NewnixWeb.Components.Partials.NavbarComponent do
  use NewnixWeb, :live_component

  def render(assigns) do
    ~H"""
      <nav aria-label="Sidebar" class="w-full h-16 flex border-b border-gray-100 px-4 justify-between">
        <div></div>
        <div class="search__  flex items-center space-x-2">
         <div class="text-gray-500 bg-gray-50 p-1 px-2 rounded-lg">
            <div class="input_group__ w-full pl-2 lg:w-96">
                <span class="icon">
                    <%= NewnixWeb.IconsView.render "search" , %{ class: "w-4 h-4" } %>
                </span>
                <input type="text" class="border-none bg-transparent text-sm" placeholder="Search">
                <div class="w-1 h-6 border-r m-auto"></div>
                <span class="icon button simple !px-3">
                    <%= NewnixWeb.IconsView.render "plus" , %{ class: "w-4 h-4" } %>
                </span>
            </div>
        </div>
        </div>
        <div class="user_menu__  flex items-center space-x-2">
          <button href="#" class="button simple"><%= NewnixWeb.IconsView.render "bell", %{class: "w-6 h-6"}%></button>
          <button href="#" class="button simple"><%= NewnixWeb.IconsView.render "person", %{class: "w-6 h-6"}%></button>
        </div>
      </nav>
    """
  end
end

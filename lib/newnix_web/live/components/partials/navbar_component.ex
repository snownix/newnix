defmodule NewnixWeb.Components.Partials.NavbarComponent do
  use NewnixWeb, :live_component

  def render(assigns) do
    ~H"""
      <nav aria-label="Sidebar" class="w-full h-16 flex bg-gray-200 border-b border-gray-100 px-4 justify-between">
        <div></div>

        <div class="user_menu__  flex items-center space-x-2">
          <.ui_button type="button" theme="base" class="px-4">
            <%= NewnixWeb.IconsView.render "bell", %{class: "w-6 h-6"}%>
          </.ui_button>
          <.ui_button type="button" theme="base" class="px-4">
            <%= NewnixWeb.IconsView.render "person", %{class: "w-6 h-6"}%>
          </.ui_button>
        </div>
      </nav>
    """
  end
end

defmodule NewnixWeb.Components.Cards.EmptyStateComponent do
  use NewnixWeb, :live_component

  attr :title, :string
  attr :href, :string, default: "#"
  attr :icon, :string, default: "folder-plus"

  def render(assigns) do
    ~H"""
      <div class="text-center flex-1 m-auto">
          <.ui_icon class="mx-auto h-12 w-12 text-gray-400" icon={@icon}/>

          <h3 class="mt-2 text-sm font-medium text-gray-900">No <%= @title %>s</h3>
          <p class="mt-1 text-sm text-gray-500">Get started by creating a new <%= @title %>.</p>
          <div class="flex justify-center mt-6">
              <.ui_button href={@href} size="small">
                <%= NewnixWeb.IconsView.render "plus", %{class: "w-6 h-6"}%>
                New <%= @title %>
              </.ui_button>
          </div>
      </div>
    """
  end
end

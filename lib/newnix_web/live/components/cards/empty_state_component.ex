defmodule NewnixWeb.Components.Cards.EmptyStateComponent do
  use NewnixWeb, :live_component

  attr :title, :string
  attr :href, :string, default: "#"

  def render(assigns) do
    ~H"""
      <div class="text-center m-auto">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m-9 1V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">No <%= @title %>s</h3>
          <p class="mt-1 text-sm text-gray-500">Get started by creating a new <%= @title %>.</p>
          <div class="mt-6">
              <.ui_button href={@href} size="small">
                <%= NewnixWeb.IconsView.render "plus", %{class: "w-6 h-6"}%>
                New <%= @title %>
              </.ui_button>
          </div>
      </div>
    """
  end
end

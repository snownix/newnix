defmodule NewnixWeb.Live.Components.Cards.ListDropComponent do
  use NewnixWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:active, assigns[:active] || true)}
  end

  def handle_event("open", _, socket) do
    {:noreply, socket |> assign(:active, !socket.assigns.active)}
  end

  def render(assigns) do
    ~H"""
    <div class={"list_drop__  #{@active && "active" || ""}"}>
        <h3 class="list_drop_title__" phx-click="open" phx-target={@myself}>
            <span class="list_icon__">
                <%= NewnixWeb.IconsView.render "chevron-down" , %{ class: "down w-3.5" } %>
                <%= NewnixWeb.IconsView.render "chevron-right" , %{ class: "right w-3.5" } %>
            </span>
            <span>
              <%= render_slot(@title) %>
            </span>
        </h3>
        <ul class="list_drop_content__">
          <%= render_slot(@list) %>
        </ul>
    </div>
    """
  end
end

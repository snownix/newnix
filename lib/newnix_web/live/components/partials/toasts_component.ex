defmodule NewnixWeb.Live.Components.Partials.ToastsComponent do
  use NewnixWeb, :live_component

  attr :toasts, :map, default: []

  def render(assigns) do
    ~H"""
      <section class="absolute right-0 top-0 h-full">
        <div class="space-y-2">
          <%= for toast <- @toasts do  %>
            <.toast
              {toast}
              phx-target={@myself}
              phx-click="toast-close"
              phx-value-id={toast.id}  />
          <% end %>
        </div>
      </section>
    """
  end

  def handle_event("toast-close", %{"id" => id}, socket) do
    {:noreply, socket |> assign(toasts: Enum.filter(socket.assigns.toasts, &(&1.id !== id)))}
  end
end

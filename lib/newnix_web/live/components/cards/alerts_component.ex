defmodule NewnixWeb.Live.Components.AlertsComponent do
  use NewnixWeb, :live_component

  attr :phx_target, :string, default: nil
  attr :close, :boolean, default: true

  def render(assigns) do
    ~H"""
      <div class="alerts" >
        <%= if message = live_flash(@flash, :info) do %>
            <.ui_alert theme="info" icon="info" close={@close} phx_target={@phx_target}><%= message %></.ui_alert>
        <% end %>

        <%= if message = live_flash(@flash, :error) do %>
            <.ui_alert theme="error" icon="danger" close={@close} phx_target={@phx_target}><%= message %></.ui_alert>
        <% end %>

        <%= if message = live_flash(@flash, :success) do %>
            <.ui_alert theme="success" icon="check" close={@close} phx_target={@phx_target}><%= message %></.ui_alert>
        <% end %>
    </div>
    """
  end
end

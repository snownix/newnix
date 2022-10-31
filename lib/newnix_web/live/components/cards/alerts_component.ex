defmodule NewnixWeb.Components.AlertsComponent do
  use NewnixWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="alerts" >
        <%= if message = live_flash(@flash, :info) do %>
            <div class="alert info">
                <svg class="inline flex-shrink-0 w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>
                <span class="message"><%= message %></span>
                <.close_icon />
            </div>
        <% end %>
        <%= if message = live_flash(@flash, :error) do %>
            <div class="alert error">
                <svg class="inline flex-shrink-0 w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>
                <span class="message"><%= message %></span>
                <.close_icon />
            </div>
        <% end %>
        <%= if message = live_flash(@flash, :success) do %>
            <div class="alert success">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="inline flex-shrink-0 w-5 h-5" fill="currentColor"><path d="M0 0h24v24H0V0z" fill="none"/><path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"/></svg>
                <span class="message"><%= message %></span>
                <.close_icon />
            </div>
        <% end %>
    </div>
    """
  end

  def close_icon(assigns) do
    ~H"""
    <span class="close" phx-click="lv:clear-flash">
      <.ui_icon class="" icon="close"/>
    </span>
    """
  end
end

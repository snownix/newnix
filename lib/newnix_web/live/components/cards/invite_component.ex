defmodule NewnixWeb.Live.Components.Cards.InviteComponent do
  use NewnixWeb, :live_component

  def render(assigns) do
    ~H"""
      <li class="flex items-center py-5 px-4 sm:py-6">
        <div class="relative min-w-0 flex-1 flex items-center">
            <div class="flex-shrink-0">
              <.ui_avatar text="AB" avatar={@project.logo}></.ui_avatar>
            </div>
            <div class="min-w-0 flex-1 px-4 md:grid md:grid-cols-3 md:gap-4">
              <div class="col-span-2">
                  <p class="font-medium text-primary-500"><%= @project.name %></p>
                  <p class="text-sm font-medium text-gray-500">
                    Invited you to join the project.
                  </p>
              </div>
              <div class="hidden md:block">
                  <div>
                    <p class="text-sm text-gray-900">
                        <.ui_datetime_display time={@invite.inserted_at} />
                    </p>
                    <p class="mt-2 flex items-center text-sm text-gray-500">
                        <%= @invite.email %>
                    </p>
                  </div>
              </div>
            </div>
            <.link navigate={Routes.project_path(@socket, :open, @project.id)} class="absolute inset-0"></.link>
        </div>
        <div class="flex space-x-2 p-2" :if={@invite.status === :pending}>
          <.ui_button size="xs" theme="dark" phx-click="accept" phx-value-id={@invite.id}>
            <.ui_icon icon="check" />
          </.ui_button>
          <.ui_button size="xs" theme="danger" phx-click="reject" phx-value-id={@invite.id}>
            <.ui_icon icon="close" />
          </.ui_button>
        </div>
        <div :if={@invite.status !== :pending} class="flex space-x-2 p-2 capitalize">
          <span class={"label #{@invite.status == :accepted && "success" || "warning"}"}><%= @invite.status %></span>
        </div>
    </li>
    """
  end
end

defmodule NewnixWeb.Components.Cards.ProjectComponent do
  use NewnixWeb, :live_component

  def render(assigns) do
    ~H"""
      <li>
        <.link href={Routes.project_path(@socket, :open, @project.id)} class="flex items-center py-5 px-4 sm:py-6">
              <div class="min-w-0 flex-1 flex items-center">
                  <div class="flex-shrink-0">
                    <.ui_avatar text="AB" avatar={@project.logo}></.ui_avatar>
                  </div>
                  <div class="min-w-0 flex-1 px-4 md:grid md:grid-cols-3 md:gap-4">
                    <div class="col-span-2">
                        <p class="font-medium text-primary-500 truncate"><%= @project.name %></p>
                        <p class="text-sm font-medium text-gray-500 truncate">
                          <%= @project.description %>
                        </p>
                    </div>
                    <div class="hidden md:block">
                        <div>
                          <p class="text-sm text-gray-900">
                              <.ui_datetime_display time={@project.inserted_at} />
                          </p>
                          <p class="mt-2 flex items-center text-sm text-gray-500">
                              <%= @project.id %>
                          </p>
                        </div>
                    </div>
                  </div>
              </div>
              <div >
                <svg class="h-5 w-5 text-gray-400 group-hover:text-gray-700" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                </svg>
              </div>
        </.link>
    </li>
    """
  end
end

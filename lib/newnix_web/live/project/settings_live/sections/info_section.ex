defmodule NewnixWeb.Live.Project.SettingsLive.Sections.InfoSection do
  use NewnixWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <section class="flex flex-1 pt-8">
        <div class="hidden md:block w-1/3 md:pr-4">
              <b><%= gettext "Project Information" %></b>
              <p><%= gettext "Update your Project information." %></p>
          </div>
          <div class="flex-1">
              <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save" class="space-y-4">
                  <div>
                      <.ui_input
                          form={f}
                          name={:name}
                          class="!bg-opacity-20 border"
                          title="Project Name" />
                  </div>

                  <div>
                      <.ui_textarea form={f} name={:description} class="!bg-opacity-20 border" title="Description" />
                  </div>

                  <div class="flex justify-end">
                      <.ui_button class="!w-fit" theme="dark" size="small">
                          <%= gettext "Update" %>
                      </.ui_button>
                  </div>
              </.form>
          </div>
      </section>
    """
  end
end

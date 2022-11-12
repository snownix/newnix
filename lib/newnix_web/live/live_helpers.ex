defmodule NewnixWeb.LiveHelpers do
  import Phoenix.Component
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  @spec rightbar_modal(any) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.rightbar_modal return_to={Routes.abc_index_path(@socket, :index)}>
        <.live_component
          module={NewnixWeb.AbcLive.FormComponent}
          id={@abc.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.abc_index_path(@socket, :index)}
          abc: @abc
        />
      </.rightbar_modal>
  """
  def rightbar_modal(assigns) do
    ~H"""
    <div id="modal" class="phx-rightbar-modal fade-in" phx-remove={hide_modal()}>
      <div class="absolute w-full h-full top-0 left-0" phx-click={JS.dispatch("click", to: "#close")}></div>
      <div
        id="modal-content"
        class={"phx-rightbar-modal-content fade-in-scale #{assigns[:class]}"}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if assigns[:return_to] do %>
          <%= live_patch "✖",
            to: @return_to,
            id: "close",
            class: "phx-rightbar-modal-close",
            phx_click: hide_modal()
          %>
        <% else %>
          <a id="close" href="#" class="phx-rightbar-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end

defmodule NewnixWeb.Live.Components.Helper do
  use Phoenix.Component

  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
  import Phoenix.LiveView.Helpers
  import NewnixWeb.ErrorHelpers

  def ui_input(assigns, form, name, attrs \\ []) do
    title = Keyword.get(attrs, :title, nil)

    ~H"""
      <div class="input_group" field-error={tag_has_error(form, name)}>
        <%= text_input form, name, attrs %>
        <%= label form, name, title %>
      </div>
    """
  end

  attr :style, :string
  attr :rest, :global
  slot(:inner_block, required: true)

  def ui_button(assigns) do
    ~H"""
      <button {@rest} class={"button " <> @style}>
        <%= render_slot(@inner_block) %>
      </button>
    """
  end
end

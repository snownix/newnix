defmodule NewnixWeb.Live.Components.Helper do
  use Phoenix.Component

  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
  import Phoenix.LiveView.Helpers
  import NewnixWeb.ErrorHelpers

  def ui_input(assigns, form, name, attrs \\ []) do
    title = Keyword.get(attrs, :title, nil)

    ~H"""
      <div class="input_group" field-error={tag_has_error(form, name)}
        field-fill={is_fill(form, name)}>
        <%= text_input form, name, attrs %>
        <%= label form, name, title %>
      </div>
    """
  end

  slot(:inner_block, required: true)
  attr :rest, :global, include: ~w(form)
  attr :theme, :string, default: "simple"
  attr :class, :string, default: ""
  attr :href, :string, default: nil

  def ui_button(assigns) do
    ~H"""
      <%= if !is_nil(@href) do %>
        <a class={@class <> " button " <> @theme} {@rest} href={@href}>
          <%= render_slot(@inner_block) %>
        </a>
      <% else %>
        <button class={@class <> " button " <> @theme} {@rest} >
          <%= render_slot(@inner_block) %>
        </button>
      <% end %>
    """
  end

  def is_fill(form, name),
    do: !is_nil(input_value(form, name)) && input_value(form, name) !== ""
end

defmodule NewnixWeb.Live.Components.Helper do
  use Phoenix.Component

  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
  import NewnixWeb.ErrorHelpers

  attr :rest, :global, include: ~w(form required value)
  attr :name, :string, required: true
  attr :form, :string, required: true
  attr :title, :string, required: true
  attr :type, :string, default: "text"

  def ui_input(assigns) do
    ~H"""
      <label class="input_group" field-error={tag_has_error(@form, @name)}
        field-fill={is_fill(@form, @name)}>
        <%= text_input @form, @name, type: @type %>
        <%= label @form, @name, @title %>
      </label>
    """
  end

  attr :rest, :global, include: ~w(form required value)
  attr :name, :string, required: true
  attr :form, :string, required: true
  attr :title, :string, required: true

  def ui_textarea(assigns) do
    ~H"""
      <label class="input_group" field-error={tag_has_error(@form, @name)}
        field-fill={is_fill(@form, @name)} phx-update="ignore" id={@name}>
        <%= textarea @form, @name %>
        <%= label @form, @name, @title %>
      </label>
    """
  end

  slot(:inner_block, required: true)
  attr :rest, :global, include: ~w(form required)
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

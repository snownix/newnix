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
  attr :class, :string, default: ""

  def ui_input(assigns) do
    ~H"""
      <label class={"input_group #{@class}"} field-error={tag_has_error(@form, @name)} {@rest}
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
  attr :class, :string, default: ""

  def ui_textarea(assigns) do
    ~H"""
      <label class={"input_group #{@class}"} field-error={tag_has_error(@form, @name)}
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
  attr :size, :string, default: ""

  def ui_button(assigns) do
    ~H"""
      <%= if !is_nil(@href) do %>
        <.link class={"button " <> @theme <> " " <> @size <> " " <> @class} {@rest} navigate={@href}>
          <%= render_slot(@inner_block) %>
        </.link>
      <% else %>
        <button class={"button " <> @theme <> " " <> @size <> " " <> @class} {@rest} >
          <%= render_slot(@inner_block) %>
        </button>
      <% end %>
    """
  end

  attr :avatar, :string, default: nil
  attr :text, :string, default: ""

  def ui_avatar(assigns) do
    ~H"""
      <div class="flex items-center justify-center border h-12 w-12 rounded-full group-hover:opacity-75">
        <%= if !is_nil(@avatar) do %>
          <img src={@avatar} />
        <% else %>
          <span><%= @text %></span>
        <% end %>
      </div>
    """
  end

  attr :time, :string

  def ui_datetime(%{time: time} = assigns) do
    timeFormated = Calendar.strftime(time, "%Y-%m-%d %H:%M:%S")

    ~H"""
      <time class="font-semibold text-gray-500" datetime={time}><%= timeFormated %></time>
    """
  end

  def is_fill(form, name),
    do: !is_nil(input_value(form, name)) && input_value(form, name) !== ""
end

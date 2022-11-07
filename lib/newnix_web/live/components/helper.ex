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
  attr :show_error, :boolean, default: false

  def ui_input(assigns) do
    ~H"""
      <label class={"input_group #{@class}"} field-error={tag_has_error(@form, @name)} {@rest}
        field-fill={is_fill(@form, @name)}>
        <%= text_input @form, @name, type: @type %>
        <%= label @form, @name, @title, class: "label" %>
        <%= if @show_error do %>
          <%= error_tag @form , @name %>
        <% end %>
      </label>
    """
  end

  attr :rest, :global, include: ~w(form required value)
  attr :name, :string, required: true
  attr :form, :string, required: true
  attr :title, :string, required: true
  attr :type, :string, default: "text"
  attr :class, :string, default: ""

  def ui_datetime(assigns) do
    ~H"""
      <label class={"input_group #{@class}"} field-error={tag_has_error(@form, @name)} {@rest}
        field-fill={is_fill(@form, @name)}>
        <%= datetime_local_input @form, @name, type: @type %>
        <%= label @form, @name, @title, class: "label" %>
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
        field-fill={is_fill(@form, @name)} id={@name}>
        <%= textarea @form, @name %>
        <%= label @form, @name, @title, class: "label" %>
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

  slot(:inner_block, required: true)
  attr :rest, :global, include: ~w(form required value)
  attr :name, :string, required: true
  attr :form, :string, required: true
  attr :title, :string, required: true
  attr :class, :string, default: ""
  attr :options, :map, default: []

  def ui_multi_select(%{options: _options} = assigns) do
    ~H"""
      <label class={"input_group #{@class}"} field-error={tag_has_error(@form, @name)} {@rest}
        field-fill={is_fill(@form, @name)}>
        <%= render_slot(@inner_block) %>
      </label>
    """
  end

  attr :avatar, :string, default: nil
  attr :text, :string, default: ""
  attr :rest, :global, include: ~w(skl)

  def ui_avatar(assigns) do
    ~H"""
      <div class="flex items-center justify-center border h-12 w-12 rounded-full group-hover:opacity-75" {@rest}>
        <%= if !is_nil(@avatar) do %>
          <img src={@avatar} />
        <% else %>
          <span><%= @text %></span>
        <% end %>
      </div>
    """
  end

  attr :time, :string
  attr :rest, :global, include: ~w(skl)

  def ui_datetime_display(%{time: time} = assigns) do
    if is_nil(time) do
      ~H"""
      """
    else
      timeFormated = Calendar.strftime(time, "%Y-%m-%d %H:%M:%S")

      assigns = assigns |> assign(:timeFormated, timeFormated)

      ~H"""
        <time {@rest} class="font-semibold text-gray-500" datetime={@time}><%= @timeFormated %></time>
      """
    end
  end

  slot(:thead, required: true)
  slot(:tbody, required: true)
  attr :columns, :map, default: []

  def ui_table(assigns) do
    ~H"""
    <table class="table">
      <thead class="bg-gray-50">
        <tr>
          <%= render_slot(@thead) %>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-100 bg-white">
        <%= render_slot(@tbody) %>
      </tbody>
    </table>
    """
  end

  slot(:action, required: false)
  attr :title, :string, default: ""
  attr :icon, :string, default: nil

  def ui_page_head(assigns) do
    ~H"""
      <div class="px-6 lg:px-8 sm:flex sm:items-center sm:space-y-2" >
        <div class="sm:flex-auto">
          <h1 class="text-xl flex-center font-semibold text-gray-900">
            <%= if @icon do %>
              <.ui_icon class="w-7 h-7" icon={@icon}/>
            <% end %>
            <span><%= @title %></span>
          </h1>
          <p class="mt-2 text-sm text-grai"><%= @description %></p>
        </div>
        <div class="sm:ml-16 sm:flex-none">
          <%= if @action do %>
            <%= render_slot(@action) %>
          <% end %>
        </div>
      </div>
    """
  end

  attr :icon, :string, default: ""
  attr :class, :string, default: "w-5 h-5"
  attr :rest, :global, include: ~w(skl)

  def ui_icon(assigns) do
    ~H"""
    <svg class={@class} {@rest}><use href={"/images/icons.svg#icon-#{@icon}"}/></svg>
    """
  end

  attr :items, :map, default: []
  attr :levels, :map, default: []

  def ui_chart_bar(assigns) do
    assigns = assigns |> assign(:count, Enum.count(assigns.items))

    ~H"""
      <div class="chart__bar relative">
          <div
            :for={level <- @levels}
            class="absolute w-full border-t border-gray-100"
            style={"bottom: #{level.pos}%;"}>
            <div class="text-gray-400 text-sm bottom-0"><%= trunc(level.value) %></div>
          </div>
          <div class="h-full pr-10"></div>
          <div class="bar__container relative group"
              :for={item <- @items}>
              <div class={"absolute-center -bottom-6 text-sm min-w-max " <> chart_display_all(@count)}>
                <div class="w-2 h-2 rounded-full bg-gray-300 absolute-center -top-2 absolute"></div>
                <span><%= item.title %></span>
              </div>
              <div :for={bar <- item.bars} skl-full
                  class={"bar #{bar.color}"}
                  style={"height: #{bar.value}%;"}>
              </div>
          </div>
      </div>
    """
  end

  def chart_display_all(count) when count < 10, do: ""
  def chart_display_all(_), do: "hidden group-hover:block"

  def ui_loading(assigns) do
    ~H"""
    <div class="newnix-loading">
      <div class="newnix-ripple">
        <div></div><div></div>
      </div>
    </div>
    """
  end

  def is_fill(form, name),
    do: !is_nil(input_value(form, name)) && input_value(form, name) !== ""

  def string_to_color_hash(text, hash \\ 0) do
    hash =
      String.to_charlist(text)
      |> Enum.reduce(hash, fn char, hash ->
        hash = char + (Bitwise.<<<(hash, 5) - hash)
        Bitwise.&&&(hash, hash)
      end)

    {color, _hash} =
      Enum.reduce(1..3, {"#", hash}, fn i, {color, hash} ->
        val = Bitwise.&&&(Bitwise.>>>(hash, i * 8), 225 * 50)

        {
          color <> String.slice("00" <> Integer.to_string(val, 16), -2..-1),
          hash
        }
      end)

    color
  end

  def calc_success_rate(a, b) when is_number(a) and a > 0,
    do: Float.round((a - b) / a * 100, 2)

  def calc_success_rate(_a, _b), do: 0

  def skeleton_class(true), do: "skeleton"
  def skeleton_class(_), do: ""

  def subscribers_format(0), do: ""
  def subscribers_format(1), do: "Subscriber"
  def subscribers_format(_count), do: "Subscribers"

  def subscribers_icon(0), do: "face-down"
  def subscribers_icon(1), do: "user"
  def subscribers_icon(2), do: "user-group"
  def subscribers_icon(_count), do: "users"
  def skeleton_fake_data(schema, repeat \\ 1..20), do: repeat |> Enum.map(fn _ -> schema end)
end

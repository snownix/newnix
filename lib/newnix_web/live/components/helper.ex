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

  attr :rest, :global, include: ~w(form required value)
  attr :name, :string, required: true
  attr :form, :string, required: true
  attr :title, :string, required: true
  attr :class, :string, default: ""

  CssEditor

  def ui_css_editor(assigns) do
    ~H"""
      <label class={"input_group #{@class}"} field-error={tag_has_error(@form, @name)}
        field-fill={is_fill(@form, @name)} id={@name} phx-hook="CssEditor">
        <%= textarea @form, @name, hidden: true %>
        <code id="css-editor"></code>
        <%= label @form, @name, @title, class: "label" %>
      </label>
    """
  end

  attr :name, :string, required: true
  attr :form, :string, required: true
  attr :title, :string, required: true
  attr :type, :string, default: "text"
  attr :class, :string, default: ""
  attr :options, :map, default: []
  attr :show_error, :boolean, default: false
  attr :rest, :global, include: ~w(form required value)

  def ui_select(assigns) do
    ~H"""
      <label class={"input_group #{@class}"} field-error={tag_has_error(@form, @name)} {@rest}
        field-fill={is_fill(@form, @name)}>
        <%= select @form, @name, @options, type: @type %>
        <%= label @form, @name, @title, class: "label" %>
        <%= if @show_error do %>
          <%= error_tag @form , @name %>
        <% end %>
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
        <.link class={"button " <> @theme <> " " <> @size <> " " <> @class} {@rest} patch={@href}>
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
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(skl)

  def ui_datetime_display(%{time: time} = assigns) do
    if is_nil(time) do
      ~H"""
      """
    else
      timeFormated = Timex.format!(time, "%Y-%m-%d %H:%M:%S", :strftime)

      assigns = assigns |> assign(:timeFormated, timeFormated)

      ~H"""
        <time {@rest} class={"font-semibold text-gray-500 #{@class}"} datetime={@time}><%= @timeFormated %></time>
      """
    end
  end

  attr :time, :string
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(skl)

  def ui_time_ago(%{time: time} = assigns) do
    if is_nil(time) do
      ~H"""
      """
    else
      timeFormated = time |> Timex.format!("{relative}", :relative)

      assigns = assigns |> assign(:timeFormated, timeFormated)

      ~H"""
        <time {@rest} class={"font-semibold text-gray-500 #{@class}"} datetime={@time}><%= @timeFormated %></time>
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

  slot(:inner_block, required: true)
  attr :name, :string, required: true
  attr :form, :string, default: nil
  attr :checked, :boolean, default: false
  attr :rest, :global

  def ui_checkbox_toggle(assigns) do
    ~H"""
      <label class="input_group checkbox__" {@rest}>
        <.ui_toggle form={@form} name={@name} checked={@checked}>
        <%= if assigns[:inner_block] do %><%= render_slot(@inner_block) %><% end %>
        </.ui_toggle>
      </label>
    """
  end

  slot(:inner_block, required: true)
  attr :name, :string, required: true
  attr :form, :string, default: nil
  attr :checked, :boolean, default: false
  attr :position, :atom, default: :right
  attr :rest, :global

  def ui_toggle(assigns) do
    ~H"""
      <label class="checkbox_toggle__" {@rest}>
        <span :if={@position === :left} class="checkbox_name__">
          <%= if assigns[:inner_block] do %><%= render_slot(@inner_block) %><% end %>
        </span>
        <div class="relative">
          <%= checkbox @form, @name, value: (if is_nil(@form), do: @checked, else: input_value(@form, @name)), class: "sr-only peer" %>
          <div toggle class="peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 peer peer-checked:after:translate-x-full peer-checked:after:border-white peer-checked:bg-blue-600"></div>
        </div>
        <span :if={@position === :right} class="checkbox_name__">
          <%= if assigns[:inner_block] do %><%= render_slot(@inner_block) %><% end %>
        </span>
      </label>
    """
  end

  slot(:action, required: false)
  attr :title, :string, default: ""
  attr :icon, :string, default: nil

  def ui_page_head(assigns) do
    ~H"""
      <div class="px-6 lg:px-8 sm:flex sm:items-center space-y-2" >
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
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(skl)

  def ui_icon(assigns) do
    ~H"""
    <svg class={"w-5 h-5 #{@class}"} {@rest}><use href={"/images/icons.svg#icon-#{@icon}"}/></svg>
    """
  end

  attr :class, :string, default: ""
  attr :color, :string, default: "#fff"
  attr :rest, :global, include: ~w(skl)

  def ui_square_color(assigns) do
    ~H"""
      <div class={"w-4 h-4 rounded flex-shrink-0 #{@class}"} style={"background-color: #{@color};"} {@rest}></div>
    """
  end

  attr :items, :map, default: []
  attr :levels, :map, default: []

  def ui_chart_bar(assigns) do
    assigns = assigns |> assign(:count, Enum.count(assigns.items))

    ~H"""
      <div class={"chart_bar__ #{chart_size_class(@count)}"}>
          <div
            :for={level <- @levels}
            class="absolute w-full border-t border-gray-100 h-0"
            style={"bottom: #{level.pos}%;"}>
            <div class="text-gray-400 text-sm bottom-0"><%= level.value %></div>
          </div>
          <div class="h-full pr-10"></div>
          <div class="bar__container relative group"
              :for={item <- @items}>
              <div class={"absolute-center -bottom-6 text-sm min-w-max " <> chart_display_all(@count)}>
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

  def chart_size_class(count) when count > 5, do: ""
  def chart_size_class(_count), do: "large"

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
    do: Float.round(a / (a + b) * 100, 2)

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
  def skeleton_fake_data(schema, repeat \\ 20), do: 1..repeat |> Enum.map(fn _ -> schema end)
end

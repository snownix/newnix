defmodule NewnixWeb.Live.Components.Form.InputTagsComponent do
  use NewnixWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> parse_items()}
  end

  attr :rest, :global, include: ~w(form required value)
  attr :name, :string, required: true
  attr :form, :string, required: true
  attr :title, :string, required: true
  attr :type, :string, default: "text"
  attr :class, :string, default: ""
  attr :show_error, :boolean, default: false
  attr :value, :string, default: ""
  attr :items, :map, default: []

  def render(assigns) do
    ~H"""
    <div>
      <label class={"input_group #{@class}"} phx-hook="InputTags" phx-target={@myself} field-error={tag_has_error(@form, @name)} {@rest}
        field-fill={is_fill(@form, @name)}>
        <input type="text">
        <%= label @form, @name, @title, class: "label" %>
        <%= if @show_error do %>
          <%= error_tag @form , @name %>
        <% end %>

        <ul class="input_tags">
          <li :for={item <- @items} phx-click="remove-item" phx-value-v={item} phx-target={@myself}>
            <input type="hidden" name={"#{input_name(@form,@name)}[]"} value={item} />
            <%= item %>
          </li>
          <li demo :if={Enum.count(@items) === 0}>
            <a><abbr title="Your website domain name">example.com</abbr></a>
            <input type="hidden" name={"#{input_name(@form,@name)}[]"} value={nil} />
          </li>
        </ul>
      </label>
    </div>
    """
  end

  @impl true
  def handle_event("add-item", %{"v" => value}, socket) do
    {:noreply, socket |> add_item(value)}
  end

  @impl true
  def handle_event("remove-item", %{"v" => value}, socket) do
    {:noreply, socket |> remove_item(value)}
  end

  defp add_item(%{assigns: %{items: items}} = socket, value) do
    socket
    |> update(:items, fn _ -> filter_items([value | items]) end)
  end

  defp remove_item(%{assigns: %{items: items}} = socket, value) do
    socket
    |> update(:items, fn _ -> Enum.reject(items, &(&1 == value)) end)
  end

  defp parse_items(%{assigns: %{value: value, items: items}} = socket) when is_list(value) do
    socket |> assign(:items, filter_items(items ++ value))
  end

  defp parse_items(%{assigns: %{value: value, items: items}} = socket) when is_binary(value) do
    socket |> assign(:items, filter_items(items ++ String.split(value, ",")))
  end

  defp parse_items(%{assigns: %{value: nil}} = socket) do
    socket |> assign(:items, [])
  end

  defp parse_items(%{assigns: %{value: value}} = socket) do
    socket
    |> assign(:items, filter_items(value || []))
  end

  defp filter_items(items),
    do: Enum.uniq(items) |> Enum.reject(fn v -> is_nil(v) or byte_size(v) === 0 end)
end

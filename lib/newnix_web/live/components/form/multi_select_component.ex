defmodule NewnixWeb.Live.Components.Form.MultiSelectComponent do
  use NewnixWeb, :live_component

  alias Phoenix.LiveView.JS

  def update(assigns, socket) do
    %{
      id: _id,
      name: _name,
      form: _form,
      title: _title,
      options: options,
      selected: _selected
    } = assigns

    socket =
      socket
      |> assign(assigns)
      |> assign(:selected_options, filter_selected_options(options))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="input_group input_multi_select">
      <%= label @form, @name, @title, class: "label" %>
    </div>
    """
  end

  def filter_selected_options(options) do
    Enum.filter(options, &(&1.selected === true || &1.selected == "true"))
  end
end

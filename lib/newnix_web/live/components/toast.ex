defmodule NewnixWeb.Live.Components.Toast do
  use Phoenix.Component

  use Phoenix.HTML

  attr :title, :string, default: ""
  attr :avatar, :string, default: ""
  attr :message, :string, default: ""
  attr :theme, :string, default: "base"
  attr :icon, :string, default: nil
  attr :class, :string, default: ""
  attr :type, :atom, default: :unknown
  attr :attrs, :global

  def toast(%{} = assigns) do
    ~H"""
      <div
        class={"toast #{@class} #{@theme}"}
        {@attrs} >
          <.toast_image {assigns} />
          <div>
            <div :if={@title} class="ml-3 text-sm font-bold">
              <%= @title %>
            </div>
            <div :if={@message} class="ml-3 text-sm font-normal">
              <%= @message %>
            </div>
          </div>
          <.close_button />
      </div>
    """
  end

  def toast_image(%{avatar: avatar} = assigns) when byte_size(avatar) > 0 do
    ~H"""
      <img class="w-8 h-8 flex-shrink-0 rounded-full shadow-lg" src={@avatar}>
    """
  end

  def toast_image(%{icon: icon} = assigns) when byte_size(icon) > 0 do
    ~H"""
      <div
        class="icon">
        <span class="sr-only"><%= @icon %> icon</span>
        <svg class="w-5 h-5">
          <use href={"/images/icons.svg#icon-#{@icon}"} />
        </svg>
      </div>
    """
  end

  def close_button(assigns) do
    ~H"""
      <button
        type="button"
        class="ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8 dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"
        >
        <svg class="w-5 h-5"><use href="/images/icons.svg#icon-close" /></svg>
      </button>
    """
  end
end

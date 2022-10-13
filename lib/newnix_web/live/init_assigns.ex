defmodule NewnixWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:user, _params, _session, socket) do
    # code
    {:cont,
     socket
     |> assign(:sidebar, :user)
     |> assign(:page_title, "User Dashboard")}
  end

  def on_mount(:project, _params, _session, socket) do
    # code
    {:cont,
     socket
     |> assign(:sidebar, :project)
     |> assign(:page_title, "Project Dashboard")}
  end
end

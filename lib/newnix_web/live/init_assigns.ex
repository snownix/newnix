defmodule NewnixWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    {:cont, assign(socket, :page_title, "Dashboard")}
  end

  def on_mount(:user, _params, _session, socket) do
    # code
    {:cont, assign(socket, :page_title, "User Dashboard")}
  end

  def on_mount(:project, _params, _session, socket) do
    # code
    {:cont, assign(socket, :page_title, "Project Dashboard")}
  end
end

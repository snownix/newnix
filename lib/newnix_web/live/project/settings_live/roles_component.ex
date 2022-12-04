defmodule NewnixWeb.Live.Project.SettingsLive.RolesComponent do
  use NewnixWeb, :live_component

  alias Newnix.Policies

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> put_initial_assigns()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:roles, Policies.roles())
    |> assign(:permissions, Policies.permissions())
  end
end

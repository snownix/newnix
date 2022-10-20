defmodule NewnixWeb.User.DashboardLive.Index do
  use NewnixWeb, :live_user

  alias Newnix.Projects

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> fetch_projects()
  end

  defp fetch_projects(socket) do
    %{user: user} = socket.assigns

    IO.inspect(user)

    socket
    |> assign(:projects, list_projects(user))
  end

  defp list_projects(user) do
    Projects.list_projects(user)
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end

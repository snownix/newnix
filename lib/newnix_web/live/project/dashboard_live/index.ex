defmodule NewnixWeb.Project.DashboardLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> fetch_campaigns()
  end

  defp fetch_campaigns(socket) do
    %{project: project} = socket.assigns

    socket
    |> assign(:campaigns, list_campaigns(project))
  end

  defp list_campaigns(project) do
    Campaigns.list_campaigns(project)
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end

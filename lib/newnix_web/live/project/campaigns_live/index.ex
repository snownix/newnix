defmodule NewnixWeb.Project.CampaignsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns
  alias Newnix.Campaigns.Campaign

  @impl true
  def mount(_params, _session, socket) do
    project = socket.assigns.project
    {:ok, assign(socket, :campaigns, list_campaigns(project))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Campaign")
    |> assign(:campaign, Campaigns.get_campaign!(socket.assigns.project, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Campaign")
    |> assign(:campaign, %Campaign{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Campaigns")
    |> assign(:campaign, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    %{project: project} = socket.assigns

    campaign = Campaigns.get_campaign!(project, id)
    {:ok, _} = Campaigns.delete_campaign(campaign)

    {:noreply, socket |> assign(:campaigns, list_campaigns(project))}
  end

  defp list_campaigns(project) do
    Campaigns.list_campaigns(project)
  end

  def subscribers_format(0), do: ""
  def subscribers_format(1), do: "Subscriber"
  def subscribers_format(_count), do: "Subscribers"

  def subscribers_icon(0), do: "face-down"
  def subscribers_icon(1), do: "user"
  def subscribers_icon(2), do: "user-group"
  def subscribers_icon(_count), do: "users"
end

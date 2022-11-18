defmodule NewnixWeb.Live.Project.CampaignsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns
  alias Newnix.Campaigns.Campaign

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns() |> update_info()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:loading, true)
    |> assign(:campaigns, %{
      meta: nil,
      entries:
        skeleton_fake_data(%Campaign{
          name: "Loading",
          description: "Loading",
          id: "loading",
          start_at: DateTime.utc_now(),
          expire_at: DateTime.utc_now(),
          subscribers_count: 9_999_999
        })
    })
    |> fetch_records()
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    %{project: project} = socket.assigns

    campaign = Campaigns.get_campaign!(project, id)
    {:ok, _} = Campaigns.delete_campaign(campaign)

    {:noreply, socket |> fetch_records()}
  end

  @impl true
  def handle_info(:update, socket) do
    {:noreply, update_info(socket)}
  end

  defp update_info(%{assigns: %{project: project}} = socket) do
    campaigns = Campaigns.list_campaigns(project)

    socket
    |> assign(:campaigns, campaigns)
    |> assign(:loading, false)
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

  defp fetch_records(socket) do
    send(self(), :update)

    socket |> assign(:loading, true)
  end

  def current_status(campaign) do
    Campaign.campaign_status(campaign)
  end
end

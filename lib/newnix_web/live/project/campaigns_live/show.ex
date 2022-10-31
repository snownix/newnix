defmodule NewnixWeb.Project.CampaignsLive.Show do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns
  alias Newnix.Subscribers
  alias Newnix.Subscribers.Subscriber

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  def put_initial_assigns(socket) do
    socket
    |> assign(
      pagination: %{
        limit: 50
      }
    )
    |> assign(:campaign, [])
    |> assign(:subscribers, [])
  end

  def handle_params(%{"id" => id} = params, _, %{assigns: assigns} = socket) do
    %{project: project, live_action: live_action} = assigns

    campaign = fetch_campaign(project, id)

    socket =
      socket
      |> assign(:campaign, campaign)
      |> assign_subscribers(campaign)
      |> assign(:page_title, page_title(live_action, campaign))

    {:noreply, apply_action(socket, live_action, params)}
  end

  def handle_event("delete", %{"sub-id" => sub_id}, socket) do
    %{campaign: campaign} = socket.assigns

    subscriber = fetch_subscriber(campaign, sub_id)
    {:ok, _} = Subscribers.delete_subscriber(subscriber)

    {:noreply, socket |> assign_subscribers(campaign)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :new_subscriber, _params) do
    socket
    |> assign(:subscriber, %Subscriber{})
  end

  defp apply_action(socket, :edit_subscriber, %{"sub_id" => sub_id} = _params) do
    %{campaign: campaign} = socket.assigns

    socket
    |> assign(:subscriber, fetch_subscriber(campaign, sub_id))
  end

  defp assign_subscribers(socket, campaign) do
    %{metadata: metadata, entries: subscribers} = fetch_subscribers(campaign)

    socket
    |> assign(:metadata, metadata)
    |> assign(:subscribers, subscribers)
  end

  defp fetch_campaign(project, id) do
    Campaigns.get_campaign!(project, id)
  end

  defp fetch_subscriber(campaign, id) do
    Campaigns.get_campaign_subscriber!(campaign, id)
  end

  defp fetch_subscribers(campaign, opts \\ []) do
    Campaigns.list_subscribers(campaign, opts)
  end

  defp page_title(:show, campaign), do: "Show Campaign #{campaign.name}"
  defp page_title(:edit, campaign), do: "Edit Campaign #{campaign.name}"
  defp page_title(:new_subscriber, campaign), do: "New Subscriber - #{campaign.name}"
  defp page_title(:edit_subscriber, campaign), do: "Edit Subscriber - #{campaign.name}"
end

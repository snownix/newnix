defmodule NewnixWeb.Live.Project.CampaignsLive.Show do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns
  alias Newnix.Subscribers
  alias Newnix.Subscribers.Subscriber

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  def handle_params(%{"id" => id} = params, _, %{assigns: assigns} = socket) do
    %{project: project, live_action: live_action} = assigns

    campaign = fetch_campaign(project, id)

    socket =
      socket
      |> assign(:campaign, campaign)
      |> assign(:page_title, page_title(live_action, campaign))

    send(self(), :update)

    {:noreply, apply_action(socket, live_action, params)}
  end

  def handle_event("toggle-subscribe", %{"id" => sub_id}, socket) do
    %{campaign: campaign} = socket.assigns

    subscriber = fetch_subscriber(campaign, sub_id)

    toggle_subscriber(is_nil(subscriber.unsubscribed_at), subscriber, campaign)

    {:noreply, socket |> fetch_records(false)}
  end

  def handle_event("delete", %{"sub-id" => sub_id}, socket) do
    %{campaign: campaign} = socket.assigns

    subscriber = fetch_subscriber(campaign, sub_id)
    {:ok, _} = Subscribers.delete_subscriber_from_campaign(subscriber, campaign)

    {:noreply, socket |> fetch_records()}
  end

  # Paginator
  def handle_event("page", %{"page" => page}, socket) do
    {:noreply, socket |> update_table_paginator(page)}
  end

  # Paginator
  def handle_event("pagination", %{"pagination" => %{"page" => page, "limit" => limit}}, socket) do
    {:noreply, socket |> update_table_paginator(page, String.to_integer(limit))}
  end

  def handle_info(:update, socket) do
    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign_subscribers()}
  end

  def put_initial_assigns(socket) do
    socket
    |> assign(
      pagination: %{
        limit: 50
      }
    )
    |> assign(:loading, true)
    |> assign(:campaign, nil)
    |> assign(:table, %{
      metadata: nil,
      entries:
        skeleton_fake_data(%Subscriber{
          id: "loading",
          firstname: "Loading",
          lastname: "Loading",
          email: "Loading",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        })
    })
    |> put_initial_paginator()
  end

  defp put_initial_paginator(socket) do
    socket
    |> assign(:paginator, %{
      page: 1,
      limit: 20,
      order: :desc,
      order_by: :inserted_at,
      pages: 0
    })
  end

  def toggle_subscriber(false, subscriber, campaign),
    do: Subscribers.resubscribe_from_campaign(subscriber, campaign)

  def toggle_subscriber(true, subscriber, campaign),
    do: Subscribers.unsubscribe_from_campaign(subscriber, campaign)

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

  defp apply_action(socket, :show_subscriber, %{"sub_id" => sub_id} = _params) do
    %{campaign: campaign} = socket.assigns

    socket
    |> assign(:subscriber, fetch_subscriber(campaign, sub_id))
  end

  defp assign_subscribers(socket) do
    socket
    |> fetch_subscribers()
  end

  # Paginator
  defp update_table_paginator(%{assigns: %{paginator: paginator}} = socket, page, limit \\ nil) do
    paginator =
      Map.merge(paginator, %{
        page: String.to_integer(page),
        limit: limit || paginator.limit
      })

    socket
    |> assign(:paginator, paginator)
    |> fetch_subscribers()
  end

  defp fetch_subscribers(%{assigns: %{paginator: paginator, campaign: campaign}} = socket) do
    %{metadata: metadata} = table = Campaigns.list_subscribers(campaign, Map.to_list(paginator))

    socket
    |> assign(:table, table)
    |> assign(:paginator, Map.merge(paginator, metadata))
  end

  defp fetch_records(socket, loading \\ true) do
    send(self(), :update)

    socket |> assign(:loading, loading)
  end

  defp fetch_campaign(project, id) do
    Campaigns.get_campaign!(project, id)
  end

  defp fetch_subscriber(campaign, id) do
    Campaigns.get_campaign_subscriber!(campaign, id)
    |> Subscribers.fetch_campaigns()
  end

  def subscribe_action(%{unsubscribed_at: unsubscribed_at}) when is_nil(unsubscribed_at),
    do: "Unsubscribe"

  def subscribe_action(_),
    do: "Resubscribe"

  defp page_title(:show, campaign), do: "Show Campaign #{campaign.name}"
  defp page_title(:edit, campaign), do: "Edit Campaign #{campaign.name}"
  defp page_title(:new_subscriber, campaign), do: "New Subscriber - #{campaign.name}"
  defp page_title(:edit_subscriber, campaign), do: "Edit Subscriber - #{campaign.name}"
  defp page_title(:show_subscriber, campaign), do: "Show Subscriber - #{campaign.name}"
end

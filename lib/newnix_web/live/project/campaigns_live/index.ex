defmodule NewnixWeb.Live.Project.CampaignsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns
  alias Newnix.Campaigns.Campaign

  @impl true
  def mount(_params, _session, socket) do
    can_mount!(socket, :campaign, :access, fn next_socket ->
      next_socket |> put_initial_assigns()
    end)
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:loading, true)
    |> assign(:table, %{
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
    |> put_initial_paginator()
    |> update_records()
  end

  defp put_initial_paginator(socket) do
    socket
    |> assign(:paginator, %{
      page: 1,
      limit: 20,
      sort: :desc,
      order: :inserted_at,
      pages: 0,
      allowed_orders: [:inserted_at, :name, :start_at]
    })
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply,
     can_do!(socket, :campaign, :delete, fn %{assigns: %{project: project}} = socket ->
       campaign = Campaigns.get_campaign!(project, id)
       {:ok, _} = Campaigns.delete_campaign(campaign)

       socket |> fetch_records()
     end)}
  end

  # Paginator
  @impl true
  def handle_event("order", %{"name" => name}, socket) do
    sort = if socket.assigns.paginator.sort == :asc, do: :desc, else: :asc

    {:noreply,
     socket |> update_table_paginator(%{page: 1, order: String.to_atom(name), sort: sort})}
  end

  # Paginator
  @impl true
  def handle_event("page", %{"page" => page}, socket) do
    {:noreply, socket |> update_table_paginator(%{page: String.to_integer(page)})}
  end

  # Paginator
  @impl true
  def handle_event("pagination", %{"pagination" => %{"page" => page, "limit" => limit}}, socket) do
    {:noreply,
     socket
     |> update_table_paginator(%{page: String.to_integer(page), limit: String.to_integer(limit)})}
  end

  @impl true
  def handle_info(:update, socket) do
    {:noreply, update_records(socket)}
  end

  defp update_records(%{assigns: %{project: project, paginator: paginator}} = socket) do
    campaigns = Campaigns.list_campaigns(project, Map.to_list(paginator))

    socket
    |> assign(:table, campaigns)
    |> assign(:loading, false)
  end

  # Paginator
  defp update_table_paginator(%{assigns: %{paginator: paginator}} = socket, params) do
    paginator = Map.merge(paginator, params)

    socket
    |> assign(:paginator, paginator)
    |> update_records()
  end

  defp apply_action(socket, :update, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Campaign")
    |> assign(:campaign, Campaigns.get_campaign!(socket.assigns.project, id))
  end

  defp apply_action(socket, :create, _params) do
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

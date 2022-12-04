defmodule NewnixWeb.Live.Project.SubscribersLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Subscribers
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns() |> update_info()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:loading, true)
    |> assign(:campaigns, %{
      metadata: nil,
      entries: []
    })
    |> assign(:table, %{
      meta: nil,
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
    # Paginator
    |> put_initial_paginator()
  end

  defp put_initial_paginator(socket) do
    socket
    |> assign(:paginator, %{
      page: 1,
      limit: 20,
      sort: :desc,
      order: :inserted_at,
      pages: 0,
      allowed_orders: [:email, :firstname, :lastname, :inserted_at],
      all: false
    })
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(:update, socket) do
    {:noreply, update_info(socket)}
  end

  defp update_info(%{assigns: %{project: project}} = socket) do
    campaigns = list_campaigns(project)

    socket
    |> fetch_subscribers()
    |> assign(:campaigns, campaigns)
    |> assign(:loading, false)
  end

  defp fetch_records(socket) do
    send(self(), :update)

    socket |> assign(:loading, true)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subscribers")
    |> assign(:subscriber, nil)
    |> fetch_records()
  end

  defp apply_action(socket, :update, %{"id" => id}) do
    subscriber =
      Subscribers.get_subscriber!(socket.assigns.project, id)
      |> Subscribers.fetch_campaigns()

    socket
    |> assign(:page_title, "Edit Subscriber")
    |> assign(:subscriber, subscriber)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    subscriber =
      Subscribers.get_subscriber!(socket.assigns.project, id)
      |> Subscribers.fetch_campaigns()

    socket
    |> assign(:page_title, "Show Subscriber")
    |> assign(:subscriber, subscriber)
  end

  defp apply_action(socket, :create, _params) do
    socket
    |> assign(:page_title, "New Subscriber")
    |> assign(:subscriber, %Subscriber{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply,
     can_do!(socket, :subscriber, :delete, fn socket ->
       subscriber = Subscribers.get_subscriber!(socket.assigns.project, id)
       {:ok, _} = Subscribers.delete_subscriber(subscriber)
       socket |> fetch_subscribers()
     end)}
  end

  # Paginator
  def handle_event("order", %{"name" => name}, socket) do
    sort = if socket.assigns.paginator.sort == :asc, do: :desc, else: :asc

    {:noreply,
     socket |> update_table_paginator(%{page: 1, order: String.to_atom(name), sort: sort})}
  end

  # Paginator
  def handle_event("page", %{"page" => page}, socket) do
    {:noreply, socket |> update_table_paginator(%{page: String.to_integer(page)})}
  end

  # Paginator
  def handle_event("pagination", %{"pagination" => %{"page" => page, "limit" => limit}}, socket) do
    {:noreply,
     socket
     |> update_table_paginator(%{page: String.to_integer(page), limit: String.to_integer(limit)})}
  end

  # Paginator
  defp update_table_paginator(%{assigns: %{paginator: paginator}} = socket, params) do
    paginator = Map.merge(paginator, params)

    socket
    |> assign(:paginator, paginator)
    |> fetch_subscribers()
  end

  defp fetch_subscribers(%{assigns: %{project: project, paginator: paginator}} = socket) do
    opts = Map.to_list(paginator)

    %{metadata: metadata} = table = Subscribers.list_subscribers(project, opts)

    paginator = Map.merge(paginator, metadata)

    socket
    |> assign(:table, table)
    |> assign(:paginator, paginator)
  end

  defp list_campaigns(project) do
    Campaigns.list_campaigns(project)
  end
end

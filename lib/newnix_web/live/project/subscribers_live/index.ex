defmodule NewnixWeb.Live.Project.SubscribersLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Subscribers
  alias Newnix.Subscribers.Subscriber
  alias Newnix.Campaigns

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:loading, true)
    |> assign(:campaigns, %{
      meta: nil,
      entries: []
    })
    |> assign(:subscribers, %{
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
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(:update, %{assigns: assigns} = socket) do
    %{project: project} = assigns

    campaigns = list_campaigns(project)
    subscribers = list_subscribers(project)

    {:noreply,
     socket
     |> assign(:subscribers, subscribers)
     |> assign(:campaigns, campaigns)
     |> assign(:loading, false)}
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

  defp apply_action(socket, :edit, %{"id" => id}) do
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

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subscriber")
    |> assign(:subscriber, %Subscriber{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subscriber = Subscribers.get_subscriber!(socket.assigns.project, id)

    {:ok, _} = Subscribers.delete_subscriber(subscriber)

    {:noreply, assign(socket, :subscribers, list_subscribers(socket.assigns.project))}
  end

  defp list_subscribers(project) do
    Subscribers.list_subscribers(project)
  end

  defp list_campaigns(project) do
    Campaigns.list_campaigns(project)
  end
end

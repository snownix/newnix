defmodule NewnixWeb.Project.SubscribersLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Subscribers
  alias Newnix.Subscribers.Subscriber

  @impl true
  def mount(_params, _session, socket) do
    project = socket.assigns.project
    {:ok, assign(socket, :subscribers, list_subscribers(project))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Subscriber")
    |> assign(:subscriber, Subscribers.get_subscriber!(socket.assigns.project, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subscriber")
    |> assign(:subscriber, %Subscriber{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subscribers")
    |> assign(:subscriber, nil)
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
end

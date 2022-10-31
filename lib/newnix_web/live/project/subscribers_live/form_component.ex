defmodule NewnixWeb.Project.SubscribersLive.FormComponent do
  use NewnixWeb, :live_component

  alias Newnix.Subscribers

  @impl true
  def update(%{subscriber: subscriber, project: _project} = assigns, socket) do
    changeset = Subscribers.change_subscriber(subscriber)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(campaign: assigns[:campaign] || nil)
     |> assign(campaigns: assigns[:campaigns] || [])
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"subscriber" => subscriber_params}, socket) do
    changeset =
      socket.assigns.subscriber
      |> Subscribers.change_subscriber(subscriber_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"subscriber" => subscriber_params}, socket) do
    save_subscriber(socket, socket.assigns.action, subscriber_params)
  end

  defp save_subscriber(socket, :edit, subscriber_params) do
    case Subscribers.update_subscriber(socket.assigns.subscriber, subscriber_params) do
      {:ok, _subscriber} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subscriber updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_subscriber(%{assigns: assigns} = socket, :new, subscriber_params) do
    case Subscribers.create_subscriber(assigns.project, assigns[:campaign], subscriber_params) do
      {:ok, _subscriber} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subscriber created successfully")
         |> push_redirect(to: assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

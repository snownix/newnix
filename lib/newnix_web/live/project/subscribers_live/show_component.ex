defmodule NewnixWeb.Live.Project.SubscribersLive.ShowComponent do
  use NewnixWeb, :live_component

  @impl true
  def update(%{subscriber: subscriber} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end

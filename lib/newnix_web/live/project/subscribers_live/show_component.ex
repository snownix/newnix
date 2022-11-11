defmodule NewnixWeb.Live.Project.SubscribersLive.ShowComponent do
  use NewnixWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> put_initial_assigns()}
  end

  @impl true
  def handle_event("toggle-active-camp", _, socket) do
    {:noreply,
     socket
     |> assign(:all_camps, !socket.assigns.all_camps)
     |> put_campaigns()}
  end

  defp put_initial_assigns(%{} = socket) do
    socket
    |> assign(:all_camps, false)
    |> assign(:campaigns, [])
    |> put_events()
    |> put_campaigns()
  end

  def put_campaigns(%{assigns: assigns} = socket) do
    %{subscriber: subscriber, all_camps: all_camps} = assigns

    campaigns =
      subscriber.campaign_subscribers
      |> Enum.filter(fn cs ->
        all_camps || is_nil(cs.unsubscribed_at)
      end)

    socket |> assign(:campaigns, order_campaign_by_sub(campaigns))
  end

  def put_events(%{assigns: assigns} = socket) do
    %{subscriber: subscriber} = assigns

    events =
      Enum.reduce(
        subscriber.campaign_subscribers,
        [
          %{
            id: nil,
            who: "#{subscriber.firstname} #{subscriber.lastname}",
            action: "Created",
            icon: "circle-stack",
            date: subscriber.inserted_at,
            target: nil
          }
        ],
        fn cs, acc ->
          acc ++
            [
              %{
                id: cs.campaign_id,
                who: "#{subscriber.firstname} #{subscriber.lastname}",
                action: "Joined",
                icon: "user-plus",
                date: cs.subscribed_at,
                target: subscriber.campaigns |> Enum.find(&(&1.id == cs.campaign_id))
              },
              %{
                id: cs.campaign_id,
                who: "#{subscriber.firstname} #{subscriber.lastname}",
                action: "Leave",
                icon: "logout",
                date: cs.unsubscribed_at,
                target: subscriber.campaigns |> Enum.find(&(&1.id == cs.campaign_id))
              }
            ]
        end
      )
      |> Enum.filter(&(!is_nil(&1.date)))
      |> Enum.sort_by(& &1, fn a, b ->
        Timex.compare(a.date, b.date) > 1
      end)

    socket |> assign(:events, events)
  end

  def order_campaign_by_sub(campaigns) do
    Enum.sort_by(campaigns, &(!is_nil(&1.unsubscribed_at)))
  end

  def event_color("Joined"), do: "text-green-500"
  def event_color("Leave"), do: "text-red-500"
  def event_color(_), do: "text-primary-500"
end

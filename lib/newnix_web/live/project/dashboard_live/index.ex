defmodule NewnixWeb.Project.DashboardLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns

  @periods [
    %{value: :all, label: "All time", selected: false},
    %{value: :day, label: "Last day", selected: false},
    %{value: :seven_day, label: "Last 7 days", selected: true},
    %{value: :month, label: "Last month", selected: false},
    %{value: :two_months, label: "Last 60 days", selected: false}
  ]

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  defp put_initial_assigns(%{assigns: assigns} = socket) do
    %{project_campaigns: project_campaigns} = assigns

    socket
    |> assign(:periods, @periods)
    |> assign(
      :campaigns,
      Enum.map(project_campaigns, fn [id, value] ->
        %{label: value, value: id, selected: false}
      end)
    )
    |> assign(:stats, %{
      subscribers: 0,
      unsubscribers: 0,
      rate: 0
    })
    |> put_new_stats()
  end

  def put_new_stats(%{assigns: assigns} = socket) do
    %{stats: stats, project: project, campaigns: campaigns} = assigns

    # period = selected_period(assigns)
    campaigns = selected_campaigns(assigns) |> all_or_many_campaigns(campaigns)

    newStats = Campaigns.subscribers_stats(project, campaigns)

    socket |> assign(:stats, Map.merge(stats, newStats))
  end

  # def selected_period(%{periods: periods}), do: Enum.find(periods, & &1.selected)

  def selected_campaigns(%{campaigns: campaigns}),
    do: Enum.filter(campaigns, & &1.selected) |> Enum.map(& &1.value)

  def all_or_many_campaigns([], campaigns), do: campaigns |> Enum.map(& &1.value)
  def all_or_many_campaigns(many, _campaigns), do: many

  def handle_event("select-period", %{"period" => value}, %{assigns: assigns} = socket) do
    value = String.to_atom(value)

    %{periods: periods} = assigns

    periods =
      periods
      |> Enum.map(fn per ->
        %{per | selected: per.value == value}
      end)

    {:noreply, socket |> assign(:periods, periods) |> put_new_stats()}
  end

  def handle_event("select-campaign", %{"campaign" => value}, %{assigns: assigns} = socket) do
    %{campaigns: campaigns} = assigns

    campaigns =
      campaigns
      |> Enum.map(fn c ->
        %{c | selected: c.value == value}
      end)

    {:noreply, socket |> assign(:campaigns, campaigns) |> put_new_stats()}
  end
end

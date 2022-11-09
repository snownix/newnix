defmodule NewnixWeb.Live.Project.DashboardLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns

  @periods [
    %{value: "all", label: "All time", selected: false, days: nil, type: :months},
    %{value: "day", label: "Last day", selected: false, days: 1, type: :hours},
    %{value: "seven_day", label: "Last 7 days", selected: true, days: 7, type: :days},
    %{value: "month", label: "Last month", selected: false, days: 30, type: :days},
    %{value: "two_months", label: "Last 60 days", selected: false, days: 60, type: :days}
  ]

  @green_color "bg-purpo-400"
  @red_color "bg-redo-400"
  @bar_levels 10

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp put_initial_assigns(%{assigns: assigns} = socket) do
    %{project_campaigns: project_campaigns} = assigns

    send(self(), :update)

    custom_params = get_connect_params(socket)

    socket
    |> assign(:loading, true)
    |> assign(:levels, [])
    |> assign(
      :campaigns,
      Enum.map(project_campaigns, fn [id, value] ->
        %{label: value, value: id, selected: company_selected(id, custom_params)}
      end)
    )
    |> assign(
      :periods,
      Enum.map(@periods, &%{&1 | selected: period_selected(&1.value, custom_params)})
    )
    |> assign(:stats, %{
      rate: 0,
      subscribers: 0,
      unsubscribers: 0
    })
    |> assign(:chart_stats, [])
  end

  defp company_selected(id, %{"save_states" => %{"campaign" => cid}}) when cid === id, do: true
  defp company_selected(_id, _), do: false
  defp period_selected(id, %{"save_states" => %{"period" => cid}}) when cid === id, do: true
  defp period_selected(_id, _), do: false

  def put_new_stats(%{assigns: assigns} = socket) do
    %{stats: stats, project: project, campaigns: campaigns} = assigns

    period = selected_period(assigns)

    campaigns = selected_campaigns(assigns) |> all_or_many_campaigns(campaigns)

    stats =
      stats
      |> Map.merge(
        Campaigns.subscribers_stats(project, campaigns, start_date: calc_period(period))
      )

    stats = stats |> Map.merge(%{rate: calc_success_rate(stats.subscribers, stats.unsubscribers)})

    {chart_stats, levels} =
      Campaigns.subscribers_chart_stats(project, campaigns,
        start_date: calc_period(period),
        format_date: period.type
      )
      |> map_chart_stats()

    socket
    |> assign(:stats, stats)
    |> assign(:levels, levels)
    |> assign(:chart_stats, chart_stats)
    |> assign(:loading, false)
  end

  defp map_chart_stats(nil), do: {[], []}
  defp map_chart_stats([]), do: {[], []}

  defp map_chart_stats(stats) do
    maxRecord =
      Enum.max_by(stats, fn d ->
        d.subscribers + d.unsubscribers
      end)

    maxSubs = maxRecord.subscribers + maxRecord.unsubscribers

    level_val = 100 / @bar_levels

    levels =
      Enum.map(1..@bar_levels, fn i ->
        %{pos: level_val * (i - 1), value: maxSubs / @bar_levels * i}
      end)

    stats =
      stats
      |> Enum.map(fn d ->
        %{
          title: d.day_date,
          bars: [
            %{
              value: Float.round(d.subscribers / maxSubs * 100, 2),
              color: @green_color
            },
            %{
              value: Float.round(d.unsubscribers / maxSubs * 100, 2),
              color: @red_color
            }
          ]
        }
      end)

    {stats, levels}
  end

  defp calc_period(%{days: nil}), do: nil

  defp calc_period(%{days: days}) when days > 0 do
    Timex.shift(DateTime.utc_now(), days: -days)
  end

  defp selected_period(%{periods: periods}), do: Enum.find(periods, & &1.selected) || %{days: nil}

  defp selected_campaigns(%{campaigns: campaigns}),
    do: Enum.filter(campaigns, & &1.selected) |> Enum.map(& &1.value)

  def all_or_many_campaigns([], campaigns), do: campaigns |> Enum.map(& &1.value)
  def all_or_many_campaigns(many, _campaigns), do: many

  def handle_event("select-period", %{"period" => value}, socket) do
    send(self(), :update)

    {:noreply,
     socket
     |> assign(:loading, true)
     |> switch_period(value)}
  end

  def handle_event("select-campaign", %{"campaign" => value}, socket) do
    send(self(), :update)

    {:noreply,
     socket
     |> assign(:loading, true)
     |> switch_campaign(value)}
  end

  def handle_info(:update, socket) do
    {:noreply, socket |> put_new_stats()}
  end

  defp switch_period(%{assigns: assigns} = socket, value) do
    %{periods: periods} = assigns

    socket
    |> assign(
      :periods,
      periods
      |> Enum.map(fn per ->
        %{per | selected: per.value == value}
      end)
    )
  end

  defp switch_campaign(%{assigns: assigns} = socket, value) do
    %{campaigns: campaigns} = assigns

    socket
    |> assign(
      :campaigns,
      campaigns
      |> Enum.map(fn c ->
        %{c | selected: c.value == value}
      end)
    )
  end
end

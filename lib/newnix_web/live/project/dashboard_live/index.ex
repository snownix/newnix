defmodule NewnixWeb.Live.Project.DashboardLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Campaigns
  alias Newnix.Subscribers

  @bar_levels 10
  @red_color "bg-redo-400 text-redo-400"
  @green_color "bg-purpo-400 text-purpo-400"

  @periods [
    %{value: "all", label: "All time", selected: false, items: nil, unit: :months},
    %{value: "day", label: "Last day", selected: false, items: 24, unit: :hours},
    %{value: "seven_day", label: "Last 7 days", selected: true, items: 7, unit: :days},
    %{value: "month", label: "Last month", selected: false, items: 30, unit: :days},
    %{value: "two_months", label: "Last 60 days", selected: false, items: 60, unit: :days}
  ]

  def mount(_params, _session, %{assigns: %{project: project}} = socket) do
    if connected?(socket), do: Subscribers.subscribe(project.id)

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
      Enum.map(project_campaigns, fn campaign ->
        %{
          label: campaign.name,
          value: campaign.id,
          selected: company_selected(campaign.id, custom_params)
        }
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
    |> assign(:latest_subscribers, [])
  end

  defp company_selected(id, %{"states" => %{"campaign" => cid}}) when cid === id, do: true
  defp company_selected(_id, _), do: false
  defp period_selected(id, %{"states" => %{"period" => cid}}) when cid === id, do: true
  defp period_selected(_id, _), do: false

  def put_latest_subscribers(%{assigns: assigns} = socket) do
    %{project: project} = assigns

    %{entries: entries} = Subscribers.list_subscribers(project, limit: 5)

    socket |> assign(:latest_subscribers, entries)
  end

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
        format_date: period.unit
      )
      |> ensure_period_interval(period)
      |> map_chart_stats()

    socket
    |> assign(:stats, stats)
    |> assign(:levels, levels)
    |> assign(:chart_stats, chart_stats)
    |> assign(:loading, false)
  end

  defp ensure_period_interval(chart_stats, %{items: nil}), do: chart_stats

  defp ensure_period_interval(chart_stats, %{unit: unit, items: items} = period) do
    generate_period_interval(unit, items, start_date: calc_period(period))
    |> Enum.map(fn {:ok, date} ->
      Enum.find(chart_stats, &(&1.day_date == date)) ||
        %{
          subscribers: 0,
          unsubscribers: 0,
          day_date: date
        }
    end)
  end

  defp map_chart_stats(nil), do: {[], []}
  defp map_chart_stats([]), do: {[], []}

  defp map_chart_stats(stats) do
    maxRecord =
      Enum.max_by(stats, fn d ->
        d.subscribers + d.unsubscribers
      end)

    maxSubs = maxRecord.subscribers + maxRecord.unsubscribers
    maxSubs = if maxSubs !== 0, do: maxSubs, else: 1

    max_levels = if maxSubs > @bar_levels, do: @bar_levels, else: maxSubs
    level_val = 100 / max_levels

    levels =
      Enum.map(1..max_levels, fn i ->
        value = trunc(maxSubs / max_levels * i)
        %{pos: level_val * i, value: value}
      end)

    stats =
      stats
      |> Enum.map(fn d ->
        %{
          title: d.day_date,
          max: d.subscribers + d.unsubscribers,
          bars: [
            %{
              real: d.unsubscribers,
              value: Float.round(d.unsubscribers / maxSubs * 100, 2),
              color: @red_color
            },
            %{
              real: d.subscribers,
              value: Float.round(d.subscribers / maxSubs * 100, 2),
              color: @green_color
            }
          ]
        }
      end)

    {stats, levels}
  end

  defp calc_period(%{items: nil}), do: nil

  defp calc_period(%{items: items, unit: unit}) when items > 0 do
    Timex.shift(DateTime.utc_now(), [{unit, -items}])
  end

  def semi_cercle_deg(perc) do
    180 * perc / 100
  end

  defp selected_period(%{periods: periods}),
    do: Enum.find(periods, & &1.selected) || %{items: nil, unit: :months}

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
    {:noreply, socket |> update_info()}
  end

  def handle_info({Subscribers, [:subscriber, _event], _result}, socket) do
    {:noreply, socket |> update_info()}
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

  defp update_info(socket) do
    socket |> put_new_stats() |> put_latest_subscribers
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

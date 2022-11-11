defmodule Newnix.Helper do
  def generate_period_interval(unit, n, ops \\ []) do
    date = Keyword.get(ops, :start_date, DateTime.utc_now())

    Timex.Interval.new(from: date, until: [{unit, n}])
    |> Timex.Interval.with_step([{unit, 1}])
    |> Enum.map(&map_period_interval(&1, unit))
  end

  def map_period_interval(date_time, unit) do
    Timex.format(date_time, format_period_interval(unit), :strftime)
  end

  def format_period_interval(:hours), do: "%H"
  def format_period_interval(:days), do: "%d-%m-%Y"
  def format_period_interval(:months), do: "%m-%Y"
end

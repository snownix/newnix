defmodule DateHelper do
  def generate_period_interval(unit, n, ops \\ []) do
    date = start_date(ops)

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

  def start_date(start_date: date), do: date
  def start_date(_), do: DateTime.utc_now()
end

start_date = Timex.shift(DateTime.utc_now(), days: 100)

IO.inspect(Test.generate_period_interval(:days, 31, start_date))
IO.inspect(Test.generate_period_interval(:months, 12, start_date))
IO.inspect(Test.generate_period_interval(:hours, 24, start_date))

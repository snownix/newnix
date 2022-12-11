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

  def auth_providers_enabled() do
    true in [
      auth_provider_enabled(:twitter),
      auth_provider_enabled(:google),
      auth_provider_enabled(:github)
    ]
  end

  def auth_provider_enabled(provider) when provider in [:twitter, :github, :google] do
    not (Application.get_env(
           :ueberauth,
           case provider do
             :twitter -> Ueberauth.Strategy.Twitter.OAuth
             :github -> Ueberauth.Strategy.Github.OAuth
             :google -> Ueberauth.Strategy.Google.OAuth
           end
         )
         |> Keyword.values()
         |> Enum.any?(&is_nil/1))
  end
end

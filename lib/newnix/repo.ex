defmodule Newnix.Repo do
  use Ecto.Repo,
    otp_app: :newnix,
    adapter: Ecto.Adapters.Postgres

  use Paginator

  def secure_allowed_limit(limit) when limit > 0 and limit < 100, do: limit
  def secure_allowed_limit(_limit), do: 50
end

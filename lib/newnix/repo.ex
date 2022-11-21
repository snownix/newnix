defmodule Newnix.Repo do
  use Ecto.Repo,
    otp_app: :newnix,
    adapter: Ecto.Adapters.Postgres
end

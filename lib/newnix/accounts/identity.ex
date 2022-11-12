defmodule Newnix.Accounts.Identity do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime_usec]

  import Ecto.Changeset

  alias Newnix.Accounts.User

  schema "identities" do
    field :provider, Ecto.Enum, values: [:github, :google, :twitter]
    field :provider_id, :string

    belongs_to :user, User, foreign_key: :user_id, type: :binary_id

    timestamps()
  end

  def changeset(data, params \\ %{}) do
    data
    |> cast(params, [:provider, :provider_id])
    |> validate_required([:provider, :provider_id])
    |> unique_constraint([:provider, :provider_id])
  end
end

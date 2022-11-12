defmodule NewnixWeb.Live.Project.FormsLive.PreviewComponent do
  use NewnixWeb, :live_component

  import Ecto.Changeset, only: [get_field: 2]

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def get_field_by_name(changeset, field, default \\ nil) do
    get_field(changeset, field) || default
  end

  def get_field_boolean(changeset, field, default \\ false) do
    get_field(changeset, field) in ["true", true] || default
  end
end

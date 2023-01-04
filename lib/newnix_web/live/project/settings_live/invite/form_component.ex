defmodule NewnixWeb.Live.Project.SettingsLive.Invite.FormComponent do
  use NewnixWeb, :live_component

  alias Newnix.Policies
  alias Newnix.Projects
  alias Newnix.Projects.Invite

  def update(%{project: _project} = assigns, socket) do
    changeset =
      Projects.change_invite(%Invite{
        expire_at: Timex.shift(Timex.now(), days: 30)
      })

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:roles, roles_list())
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"invite" => invite_params}, socket) do
    changeset =
      %Invite{
        expire_at: Timex.shift(Timex.now(), days: 30)
      }
      |> Projects.change_invite(invite_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"invite" => invite_params}, %{assigns: assigns} = socket) do
    %{project: project, user: user} = assigns

    case Projects.create_invite(project, user, invite_params) do
      {:ok, invite} ->
        Projects.delivery_invite_instructions(
          %{
            invite: invite,
            sender: user,
            project: project
          },
          Routes.user_invites_index_path(socket, :index)
        )

        {:noreply,
         socket
         |> put_flash(:info, "Member invited successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp roles_list() do
    Policies.roles() |> Enum.map(&{&1, &1})
  end

  def expire_at(changeset) do
    Invite.expire_at(changeset)
  end
end

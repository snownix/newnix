defmodule NewnixWeb.Live.User.InvitesLive.Index do
  use NewnixWeb, :live_user

  alias Newnix.Projects

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("accept", %{"id" => id}, socket) do
    {:noreply, socket |> answer_invite(id, :accepted)}
  end

  def handle_event("reject", %{"id" => id}, socket) do
    {:noreply, socket |> answer_invite(id, :rejected)}
  end

  defp answer_invite(%{assigns: %{current_user: current_user}} = socket, id, answer) do
    invite = Projects.get_invite!(current_user, id)

    {:ok, _} = Projects.answer_invite(current_user, invite, answer)

    socket
    |> fetch_invites()
  end

  defp put_initial_assigns(socket) do
    socket
    |> fetch_invites()
  end

  defp fetch_invites(%{assigns: %{current_user: current_user}} = socket) do
    socket
    |> assign(:invites, list_invites(current_user))
  end

  defp list_invites(user) do
    Projects.list_invites(user)
  end
end

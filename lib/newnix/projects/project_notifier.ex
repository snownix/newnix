defmodule Newnix.Projects.ProjectNotifier do
  use Phoenix.Swoosh,
    view: NewnixWeb.EmailView,
    layout: {NewnixWeb.LayoutView, :email}

  import Swoosh.Email

  alias Newnix.Mailer

  defp init_assigns() do
    %{
      app: "Newnix",
      support_email: Newnix.config([:mailing, :support])
    }
  end

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, view, data = %{}) do
    assigns =
      Map.merge(init_assigns(), %{subject: subject})
      |> Map.merge(data)

    email =
      new()
      |> to(recipient)
      |> subject(subject)
      |> from({"Newnix - Project", Newnix.config([:mailing, :noreply])})
      |> render_body(view, assigns)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm project deletion to the user.
  """
  def deliver_delete_confirmation(project, user, url, client_agent) do
    deliver(
      user.email,
      "Project delete confirmation",
      "project_delete_confirmation.html",
      Map.merge(client_agent, %{
        url: url,
        user: user,
        project: project
      })
    )
  end

  @doc """
  Deliver invite instructions to the receiver.
  """
  def delivery_invite_instructions(
        %{
          invite: invite,
          sender: sender,
          project: project
        } = assigns,
        url
      ) do
    deliver(
      invite.email,
      "#{sender.firstname} has invited you to join #{project.name}",
      "project_user_invitation.html",
      assigns |> Map.merge(%{url: url})
    )
  end
end

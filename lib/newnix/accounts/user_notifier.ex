defmodule Newnix.Accounts.UserNotifier do
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
      |> from({"Newnix", Newnix.config([:mailing, :noreply])})
      |> render_body(view, assigns)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", "account_confirmation.html", %{
      url: url,
      user: user
    })
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url, client_agent) do
    deliver(
      user.email,
      "Reset password instructions",
      "reset_password.html",
      Map.merge(client_agent, %{
        url: url,
        user: user
      })
    )
  end
end

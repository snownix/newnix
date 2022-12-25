defmodule NewnixWeb.Live.AuthLive.ForgotPassword do
  use NewnixWeb, :live_auth

  alias Newnix.Accounts

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Forgot Password"))
     |> assign(:client_agent, parse_client_agent(get_connect_params(socket)))
     |> assign(
       :changeset,
       Accounts.user_email_changeset(%Accounts.User{})
     )}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.user_email_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event(
        "update",
        %{"user" => user_params},
        %{assigns: %{client_agent: client_agent}} = socket
      ) do
    %{"email" => email} = user_params

    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &Routes.auth_reset_password_url(socket, :reset, &1),
        client_agent
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext(
         "If your email is in our system, you will receive instructions to reset your password shortly."
       )
     )
     |> redirect(to: Routes.auth_login_path(socket, :login))}
  end
end

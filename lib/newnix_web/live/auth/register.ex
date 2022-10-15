defmodule NewnixWeb.AuthLive.Register do
  use NewnixWeb, :live_auth

  alias Newnix.Accounts

  def mount(_, _, socket) do
    {:ok, put_initial_assigns(socket)}
  end

  def put_initial_assigns(socket) do
    socket
    |> assign(
      changeset: Accounts.user_register_changeset(%Accounts.User{}),
      page_title: gettext("Sign up"),
      trigger_submit?: false,
      show_form?: false
    )
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, show_form?: params["form"] == "true")}
  end

  def handle_event("toggle-form", _, socket) do
    {:noreply, assign(socket, :show_form?, !socket.assigns.show_form?)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.user_register_changeset(user_params, uniq_email: false)
      |> Map.put(:action, :validate)

    {:noreply, socket |> clear_flash() |> assign(:changeset, changeset)}
  end

  def handle_event("create", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.auth_confirm_url(socket, :confirm, &1)
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           gettext(
             "Registration completed successfully. please check your email to verify your account."
           )
         )
         |> assign(:trigger_submit?, true)
         |> redirect(to: Routes.auth_login_path(socket, :login))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)}
    end
  end
end

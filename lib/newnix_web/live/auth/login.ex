defmodule NewnixWeb.Live.AuthLive.Login do
  use NewnixWeb, :live_auth

  alias Newnix.Accounts

  def mount(_, _, socket) do
    {:ok, put_initial_assigns(socket)}
  end

  def put_initial_assigns(socket) do
    socket
    |> assign(
      changeset: Accounts.user_login_changeset(%Accounts.User{}),
      page_title: gettext("Sign in"),
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
      |> Accounts.user_login_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> clear_flash() |> assign(:changeset, changeset)}
  end

  def handle_event("create", %{"user" => user_params}, socket) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      {:noreply,
       socket
       |> put_flash(:info, gettext("Welcome back %{firstname}!", firstname: user.firstname))
       |> assign(:trigger_submit?, true)}
    else
      {:noreply,
       socket
       # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
       |> put_flash(:error, gettext("Invalid email or password"))}
    end
  end
end

defmodule NewnixWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  alias Newnix.Accounts
  alias Newnix.Accounts.User

  def on_mount(:user, params, session, socket) do
    socket =
      socket
      |> assign(:sidebar, :user)
      |> fetch_locale(session)
      |> set_locale(params)
      |> assign(:current_user, find_current_user(session))

    {:cont, socket}
  end

  def on_mount(:project, _params, _session, socket) do
    # code
    {:cont,
     socket
     |> assign(:sidebar, :project)
     |> assign(:page_title, "Project Dashboard")}
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  def set_locale(socket, %{"locale" => locale}) do
    put_locale(locale)

    socket
    |> assign(:locale, locale)
  end

  def set_locale(socket, _), do: socket

  defp fetch_locale(socket, session) do
    locale = session["locale"] || Application.get_env(:newnix, NewnixWeb.Gettext)[:default_locale]

    put_locale(locale)

    socket |> assign(:locale, locale)
  end

  defp put_locale(nil), do: nil

  defp put_locale(locale) do
    Gettext.put_locale(NewnixWeb.Gettext, locale)
  end
end

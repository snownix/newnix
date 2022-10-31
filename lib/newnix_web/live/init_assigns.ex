defmodule NewnixWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.Component

  alias Newnix.Accounts
  alias Newnix.Accounts.User
  alias Newnix.Projects
  alias Newnix.Campaigns
  alias Newnix.Projects.Project

  def on_mount(:user, params, session, socket) do
    user = find_current_user(session)

    {:cont,
     socket
     |> assign(:sidebar, :user)
     |> assign_locale(session, params)
     |> assign(:current_user, user)
     |> assign(:projects, Projects.list_projects(user))}
  end

  def on_mount(:project, _params, session, socket) do
    %{current_user: current_user} = socket.assigns

    socket =
      socket
      |> assign(:sidebar, :project)

    if is_nil(current_user) do
      {:cont, socket}
    else
      case find_current_project(current_user, session) do
        nil ->
          {:cont, socket}

        project ->
          campaigns = project |> Campaigns.meta_list_campaigns()

          {:cont,
           socket
           |> assign(:project, project)
           |> assign(:page_title, project.name)
           |> assign(:project_campaigns, campaigns)}
      end
    end
  end

  defp assign_locale(socket, session, params) do
    socket
    |> fetch_locale(session)
    |> set_locale(params)
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  defp find_current_project(user, session) do
    with project_id when not is_nil(project_id) <- session["project_id"],
         %Project{} = project <-
           Projects.get_project!(user, project_id),
         do: project
  end

  defp fetch_locale(socket, session) do
    locale = session["locale"] || Application.get_env(:newnix, NewnixWeb.Gettext)[:default_locale]

    put_locale(locale)

    socket |> assign(:locale, locale)
  end

  def set_locale(socket, %{"locale" => locale}) do
    put_locale(locale)

    socket
    |> assign(:locale, locale)
  end

  def set_locale(socket, _), do: socket

  defp put_locale(nil), do: nil

  defp put_locale(locale) do
    Gettext.put_locale(NewnixWeb.Gettext, locale)
  end
end

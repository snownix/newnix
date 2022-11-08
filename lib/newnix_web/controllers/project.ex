defmodule NewnixWeb.Project do
  import Plug.Conn
  import Phoenix.Controller

  alias Newnix.Projects
  alias Newnix.Projects.Project
  alias NewnixWeb.Router.Helpers, as: Routes

  defp find_project(user, session) do
    with project_id when not is_nil(project_id) <- session["project_id"],
         %Project{} = project <-
           Projects.get_project!(user, project_id),
         do: project
  end

  @doc """
  """
  def fetch_current_project(conn, _opts) do
    user = conn.assigns.current_user

    case find_project(user, get_session(conn)) do
      nil ->
        conn

      project ->
        conn
        |> assign(:project, project)
    end
  end

  @doc """
  """
  def required_project(conn, _opts) do
    if conn.assigns[:project] do
      conn
    else
      conn
      |> put_flash(:error, "You must select a project.")
      |> redirect(to: Routes.live_path(conn, NewnixWeb.Live.User.DashboardLive.Index))
      |> halt()
    end
  end
end

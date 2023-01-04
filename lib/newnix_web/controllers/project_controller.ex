defmodule NewnixWeb.ProjectController do
  use NewnixWeb, :controller

  alias Newnix.Projects

  def open(conn, %{"id" => id}) do
    project = Projects.get_project!(conn.assigns.current_user, id)

    if project do
      log_in_project(conn, id)
    else
      conn
      |> put_flash(:error, gettext("Project not found !"))
      |> redirect(to: Routes.user_dashboard_index_path(conn, :index))
    end
  end

  def log_in_project(conn, id) do
    conn
    |> put_session(:project_id, id)
    |> redirect(to: Routes.live_path(conn, NewnixWeb.Live.Project.DashboardLive.Index))
  end

  def leave(conn, _params) do
    conn
    |> delete_session(:project_id)
    |> redirect(to: Routes.user_dashboard_index_path(conn, :index))
  end
end

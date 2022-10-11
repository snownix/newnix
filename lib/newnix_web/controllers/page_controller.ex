defmodule NewnixWeb.PageController do
  use NewnixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

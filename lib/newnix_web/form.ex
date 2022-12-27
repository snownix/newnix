defmodule NewnixWeb.Form do
  import Plug.Conn
  import Phoenix.Controller

  alias Newnix.Builder

  defp find_form(id) do
    Builder.get_form!(id)
  end

  @doc """
  Fetch form plug
  """
  def fetch_form(%{params: %{"id" => id}} = conn, _opts) do
    case find_form(id) do
      nil ->
        conn

      form ->
        conn
        |> assign(:form, form)
        |> assign(:page_title, form.name)
        |> assign(:page_description, form.description)
    end
  end

  @doc """
  """
  def required_form(conn, _opts) do
    if conn.assigns[:form] do
      conn
    else
      conn
      |> put_flash(:error, "Page not found.")
      |> redirect(to: "/404")
      |> halt()
    end
  end

  @doc """
  """
  def allow_origin(conn, _opts) do
    conn
    |> delete_resp_header("x-frame-options")
    |> delete_resp_header("content-security-policy")
  end
end

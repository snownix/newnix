defmodule NewnixWeb.ProvidersController do
  use NewnixWeb, :controller

  alias Newnix.Accounts
  import NewnixWeb.UserAuth

  plug Ueberauth
  plug :prepare when action in [:request]

  @types ["login", "register"]

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    if get_session(conn, :auth_type) == "register" do
      case Accounts.register_user_from_provider(auth) do
        {:ok, user} ->
          log_in_user(conn, user)

        _ ->
          conn
          |> put_flash(:error, "Registration using this provider has been failed")
          |> redirect(to: Routes.auth_register_path(conn, :register))
      end
    else
      case Accounts.get_user_by_provider_id(auth.provider, Kernel.inspect(auth.uid)) do
        nil ->
          conn
          |> put_flash(:error, "This account has not been registered yet !")
          |> redirect(to: Routes.auth_login_path(conn, :login))

        user ->
          log_in_user(conn, user)
      end
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    IO.inspect(failure, label: "Ueberauth failed")

    if get_session(conn, :auth_type) == "register" do
      conn
      |> put_flash(:error, "Registration using this provider has been failed")
      |> redirect(to: Routes.auth_register_path(conn, :register))
    else
      conn
      |> put_flash(:error, "Login using this provider has been failed")
      |> redirect(to: Routes.auth_login_path(conn, :login))
    end
  end

  def prepare(%{query_params: %{"type" => type}} = conn, _opts) when type in @types do
    conn
    |> put_session(:auth_type, type)
  end
end

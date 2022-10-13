defmodule NewnixWeb.Router do
  use NewnixWeb, :router

  import NewnixWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NewnixWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NewnixWeb do
    pipe_through :browser

    scope "/" do
      pipe_through :require_authenticated_user

      live_session :user, on_mount: {NewnixWeb.InitAssigns, :user} do
        scope "/user", User do
          live "/", IndexLive, :user
        end
      end

      live_session :project, on_mount: {NewnixWeb.InitAssigns, :project} do
        scope "/project", Project do
          live "/", IndexLive, :project
        end
      end
    end

    scope "/account" do
      live "/confirm", AuthLive.Reconfirm, :reconfirm
      live "/confirm/:token", AuthLive.Confirm, :confirm
    end

    scope "/auth" do
      pipe_through :redirect_if_user_is_authenticated

      live "/login", AuthLive.Login, :login
      live "/register", AuthLive.Register, :register
      live "/forgot-password", AuthLive.ForgotPassword, :forgot
      live "/reset-password/:token", AuthLive.ResetPassword, :reset
    end

    ## Controllers
    scope "/auth" do
      delete "/logout", UserSessionController, :delete
    end

    scope "/auth" do
      pipe_through :redirect_if_user_is_authenticated
      post "/login", UserSessionController, :create

      get "/providers/:provider", ProvidersController, :request
      get "/providers/:provider/callback", ProvidersController, :callback
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", NewnixWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NewnixWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

defmodule NewnixWeb.Router do
  use NewnixWeb, :router

  import NewnixWeb.UserAuth
  import NewnixWeb.Project

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NewnixWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :auth do
    plug :put_root_layout, {NewnixWeb.LayoutView, "root.html"}
    plug :put_layout, {NewnixWeb.AuthView, "app.html"}
  end

  pipeline :user do
    plug :put_root_layout, {NewnixWeb.LayoutView, "root.html"}
    plug :put_layout, {NewnixWeb.UserView, "app.html"}
  end

  pipeline :project do
    plug :fetch_current_project
    plug :required_project

    plug :put_root_layout, {NewnixWeb.LayoutView, "root.html"}
    plug :put_layout, {NewnixWeb.ProjectView, "app.html"}
  end

  # User
  live_session :user, on_mount: {NewnixWeb.InitAssigns, :user} do
    scope "/", NewnixWeb do
      pipe_through [:browser, :require_authenticated_user, :user]

      get "/project/open/:id", ProjectController, :open

      scope "/", User.DashboardLive do
        live "/", Index
        live "/new", New
      end
    end
  end

  # Project
  live_session :project,
    on_mount: [{NewnixWeb.InitAssigns, :user}, {NewnixWeb.InitAssigns, :project}] do
    scope "/project", NewnixWeb.Project do
      pipe_through [:browser, :require_authenticated_user, :project]

      live "/", DashboardLive.Index

      scope "/settings", SettingsLive do
        live "/", Index
      end

      scope "/campaigns", CampaignsLive do
        live "/", Index, :index
        live "/new", Index, :new
        live "/:id/edit", Index, :edit

        live "/:id", Show, :show
        live "/:id/show/edit", Show, :edit

        live "/:id/subscriber/new", Show, :new_subscriber
        live "/:id/subscriber/:sub_id/edit", Show, :edit_subscriber
      end

      scope "/subscribers", SubscribersLive do
        live "/", Index, :index
        live "/new", Index, :new
        live "/:id/edit", Index, :edit

        live "/:id", Show, :show
        live "/:id/show/edit", Show, :edit
      end
    end
  end

  # Auth
  scope "/", NewnixWeb do
    pipe_through [:browser, :auth]

    scope "/account" do
      live "/confirm", AuthLive.Reconfirm, :reconfirm
      live "/confirm/:token", AuthLive.Confirm, :confirm
    end

    scope "/auth" do
      scope "/" do
        pipe_through :redirect_if_user_is_authenticated

        live "/login", AuthLive.Login, :login
        live "/register", AuthLive.Register, :register
        live "/forgot-password", AuthLive.ForgotPassword, :forgot
        live "/reset-password/:token", AuthLive.ResetPassword, :reset
      end

      # Controllers
      scope "/" do
        pipe_through :require_authenticated_user
        delete "/logout", UserSessionController, :delete
      end

      scope "/" do
        pipe_through :redirect_if_user_is_authenticated
        post "/login", UserSessionController, :create

        get "/providers/:provider", ProvidersController, :request
        get "/providers/:provider/callback", ProvidersController, :callback
      end
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

      live_dashboard "/dashboard",
        metrics: NewnixWeb.Telemetry,
        ecto_psql_extras_options: [long_running_queries: [threshold: "200 milliseconds"]]
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

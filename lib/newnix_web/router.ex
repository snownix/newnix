defmodule NewnixWeb.Router do
  use NewnixWeb, :router

  import NewnixWeb.UserAuth
  import NewnixWeb.Project
  import NewnixWeb.Form

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

  pipeline :form do
    plug :fetch_form
    plug :required_form
    plug :allow_origin

    plug :put_root_layout, {NewnixWeb.FormView, "root.html"}
    plug :put_layout, {NewnixWeb.FormView, "app.html"}
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

      get "/project/leave", ProjectController, :leave
      get "/project/open/:id", ProjectController, :open

      scope "/", Live.User.DashboardLive do
        live "/", Index, :index
        live "/create", New, :new
      end

      live "/invites", Live.User.InvitesLive.Index, :index
    end
  end

  # Project
  live_session :project,
    on_mount: [{NewnixWeb.InitAssigns, :user}, {NewnixWeb.InitAssigns, :project}] do
    scope "/project", NewnixWeb do
      pipe_through [:browser, :require_authenticated_user, :project]

      live "/", Live.Project.DashboardLive.Index, :index

      scope "/settings", Live.Project.SettingsLive do
        live "/", Index, :index
        live "/roles", Index, :roles

        live "/invite", Index, :invite
        live "/user/:id", Index, :user

        live "/delete/:token", Delete, :confirm
      end

      scope "/campaigns", Live.Project.CampaignsLive do
        live "/", Index, :index
        live "/create", Index, :create
        live "/:id/update", Index, :update

        live "/:id", Show, :show
        live "/:id/show/update", Show, :update

        live "/:id/subscriber/create", Show, :new_subscriber
        live "/:id/subscriber/:sub_id/update", Show, :edit_subscriber
        live "/:id/subscriber/:sub_id/show", Show, :show_subscriber
      end

      scope "/subscribers", Live.Project.SubscribersLive do
        live "/", Index, :index
        live "/create", Index, :create

        live "/:id/update", Index, :update
        live "/:id/show", Index, :show
      end

      scope "/forms", Live.Project.FormsLive do
        live "/", Index, :index
        live "/:cam_id/list", Index, :index

        live "/create", Index, :create
        live "/:id/update", Index, :update
      end

      scope "/workflows", Live.Project.WorkflowsLive do
        live "/", Index, :index
        live "/builder", Index, :create
        live "/builder/:id", Index, :update
      end

      scope "/templates", Live.Project.TemplatesLive do
        live "/", Index, :index
        live "/builder", Index, :create
        live "/builder/:id", Index, :update
      end

      scope "/integrations", Live.Project.IntegrationsLive do
        live "/", Index, :index
        live "/create", Index, :create
        live "/:id/update", Index, :update
      end
    end
  end

  # Forms
  live_session :form,
    on_mount: {NewnixWeb.InitAssigns, :form} do
    scope "/forms", NewnixWeb.Live do
      pipe_through [:browser, :form]

      live "/view/:id", Form.FormLive.Index, :index
      live "/dev/:id", Form.FormLive.Index, :dev
    end
  end

  # Auth
  scope "/", NewnixWeb do
    pipe_through [:browser, :auth]

    scope "/account", Live do
      live "/confirm", AuthLive.Reconfirm, :reconfirm
      live "/confirm/:token", AuthLive.Confirm, :confirm
    end

    scope "/auth" do
      scope "/", Live do
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

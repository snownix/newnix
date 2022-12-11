# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :newnix,
  ecto_repos: [Newnix.Repo]

config :flop,
  repo: Newnix.Repo

config :newnix, :generators, binary_id: true

# Configures the endpoint
config :newnix, NewnixWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: NewnixWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Newnix.PubSub,
  live_view: [signing_salt: "yVE0h/cY"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :newnix, Newnix.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

config :tailwind,
  version: "3.2.4",
  app: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ],
  form: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/form.css
      --output=../priv/static/assets/form.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --external:/icons/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Auth
config :ueberauth, Ueberauth,
  base_path: "/auth/providers",
  providers: [
    google:
      {Ueberauth.Strategy.Google,
       [
         default_scope: "email profile",
         prompt: "select_account",
         access_type: "offline",
         include_granted_scopes: true
       ]},
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

defmodule Newnix.MixProject do
  use Mix.Project

  def project do
    [
      app: :newnix,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      releases: [
        newnix: [
          include_erts: true,
          include_executables_for: [:unix],
          applications: [
            runtime_tools: :permanent
          ]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Newnix.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.14"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.9.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.7.1"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:oauth2, "~> 2.0", override: true},
      {:ueberauth, "~> 0.7"},
      {:ueberauth_google, "~> 0.10.1"},
      {:ueberauth_github, "~> 0.8.1"},
      {:ueberauth_twitter, "~> 0.4.1"},
      {:waffle, "~> 1.1"},
      {:waffle_ecto, "~> 0.0"},
      {:slugify, "~> 1.3"},
      {:bcrypt_elixir, "~> 2.0"},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:timex, "~> 3.0"},
      {:flop, "~> 0.18.4"},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:ecto_psql_extras, "~> 0.6"},
      {:phoenix_swoosh, "~> 1.0"},
      {:browser, "~> 0.4.4"},
      {:hackney, "~> 1.18.0"},
      {:gen_smtp, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "tailwind app --minify",
        "tailwind form --minify",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end

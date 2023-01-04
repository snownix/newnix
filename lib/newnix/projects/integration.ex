defmodule Newnix.Projects.Integration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Newnix.Accounts.User
  alias Newnix.Projects.Project
  alias Newnix.Projects.Integration.Config

  @policies %{
    access: [:admin, :manager],
    create: [:admin, :manager],
    update: [:admin],
    delete: [:admin]
  }
  def policies(), do: @policies

  @providers [
    :mailchimp,
    :mailjet,
    :mailgun,
    :sendgrid,
    :sendinblue,
    :mandrill,
    :postmark,
    :dyn,
    :mailpace,
    :smtp2go,
    :gmail,
    :sparkpost,
    :socketlabs
  ]

  @status_options [:active, :inactive, :error, :limited]
  def status_options(), do: @status_options

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "project_integrations" do
    field :name, :string

    field :status, Ecto.Enum, values: @status_options
    field :type, Ecto.Enum, values: @providers

    embeds_one :config, Config

    belongs_to :user, User
    belongs_to :project, Project

    timestamps()
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:name, :type, :status])
    |> validate_required([:name, :type, :status])
    |> cast_embed(:config,
      required: true,
      with: {
        Config,
        :changeset,
        [attrs["type"]]
      }
    )
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
  end

  def user_assoc(changeset, user) do
    changeset
    |> put_assoc(:user, user)
  end

  def detailed_providers() do
    [
      %{
        name: :mailchimp,
        title: "Mailchimp",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :mailjet,
        title: "Mailjet",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :mailgun,
        title: "Mailgun",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :sendgrid,
        title: "Sendgrid",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :sendinblue,
        title: "Sendinblue",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :mandrill,
        title: "Mandrill",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :postmark,
        title: "Postmark",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :dyn,
        title: "Dyn",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :mailpace,
        title: "Mailpace",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :smtp2go,
        title: "Smtp2go",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :gmail,
        title: "Gmail",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :sparkpost,
        title: "Sparkpost",
        description: "Create an account and obtain an API key.",
        status: :active
      },
      %{
        name: :socketlabs,
        title: "Socketlabs",
        description: "Create an account and obtain an API key.",
        status: :active
      }
    ]
  end
end

defmodule Newnix.Builder.Form do
  use Ecto.Schema
  import Ecto.Changeset

  alias Newnix.Campaigns.Campaign
  alias Newnix.Projects.Project

  @policies %{
    list: [:admin, :manager, :user],
    create: [:admin, :manager, :user],
    update: [:admin, :manager, :user],
    delete: [:admin, :manager]
  }
  def policies(), do: @policies

  @maxlen_name 40
  def maxlen_name(), do: @maxlen_name
  @maxlen_email 100
  def maxlen_email(), do: @maxlen_email
  @maxlen_description 500
  def maxlen_description(), do: @maxlen_description
  @maxlen_thanks 500
  def maxlen_thanks(), do: @maxlen_thanks
  @maxlen_button 500
  def maxlen_button(), do: @maxlen_button
  @maxlen_css 3000
  def maxlen_css(), do: @maxlen_css
  @default_email "Email address"
  def default_email(), do: @default_email
  @default_button "Join"
  def default_button(), do: @default_button
  @status_options [:draft, :active, :inactive]
  def status_options(), do: @status_options

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "builder_forms" do
    field :name, :string
    field :lang, :string
    field :description, :string

    field :domains, {:array, :string}

    field :firstname, :boolean, default: false
    field :lastname, :boolean, default: false
    field :email_text, :string
    field :button_text, :string
    field :thanks_text, :string

    field :css, :string

    field :status, Ecto.Enum, values: @status_options, default: :draft

    belongs_to :project, Project, type: :binary_id
    belongs_to :campaign, Campaign, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(form, attrs) do
    form
    |> cast(attrs, [
      :name,
      :description,
      :domains,
      :firstname,
      :lastname,
      :thanks_text,
      :email_text,
      :css,
      :button_text,
      :lang,
      :status,
      :campaign_id
    ])
    |> cast_assoc(:campaign)
    |> validate_required([
      :name,
      :status
    ])
    |> validate_length(:name, max: @maxlen_name)
    |> validate_length(:email_text, max: @maxlen_email)
    |> validate_length(:description, max: @maxlen_description)
    |> validate_length(:thanks_text, max: @maxlen_thanks)
    |> validate_length(:button_text, max: @maxlen_button)
    |> validate_length(:css, max: @maxlen_css)
  end

  def campaign_assoc(changeset, campaign) do
    changeset
    |> put_assoc(:campaign, campaign)
  end

  def project_assoc(changeset, project) do
    changeset
    |> put_assoc(:project, project)
  end
end

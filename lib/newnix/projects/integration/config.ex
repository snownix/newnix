defmodule Newnix.Projects.Integration.Config do
  use Ecto.Schema

  @providers %{
    dyn: %{title: "dyn", fields: [:api_key]},
    gmail: %{title: "Gmail", fields: [:api_key]},
    mailpace: %{title: "MailPace", fields: [:api_key]},
    mailgun: %{title: "Mailgun", fields: [:api_key, :domain]},
    mailchimp: %{title: "Mailchimp", fields: [:api_key]},
    mailjet: %{title: "Mailjet", fields: [:api_key, :api_secret]},
    mandrill: %{title: "Mandrill", fields: [:api_key]},
    postmark: %{title: "Postmark", fields: [:api_key]},
    sendgrid: %{title: "SendGrid", fields: [:api_key]},
    sendinblue: %{title: "SendinBlue", fields: [:api_key]},
    socketlabs: %{title: "SocketLabs", fields: [:api_key, :server_id]},
    smtp2go: %{title: "SMTP2go", fields: [:api_key]},
    sparkpost: %{title: "SparkPost", fields: [:api_key, :endpoint]}
  }

  import Ecto.Changeset,
    only: [
      cast: 3,
      change: 1,
      validate_change: 3,
      validate_required: 2,
      validate_format: 3
    ]

  embedded_schema do
    field :api_key, :string
    field :api_secret, :string
    field :domain, :string
    field :endpoint, :string
    field :server_id, :string
  end

  def changeset(changeset, attrs, provider) do
    changeset
    |> change()
    |> cast(attrs, [:api_key, :api_secret, :domain, :endpoint])
    |> validate_changeset(provider)
  end

  def validate_changeset(changeset, provider) when is_bitstring(provider),
    do: validate_changeset(changeset, String.to_atom(provider))

  def validate_changeset(changeset, :mailgun) do
    changeset
    |> validate_required(@providers.mailgun.fields)
    |> validate_format(:domain, ~r/^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$/)
  end

  def validate_changeset(changeset, :sparkpost),
    do:
      changeset
      |> validate_required(@providers.sparkpost.fields)
      |> validate_url(:endpoint)

  @doc """
    Validate changeset required for
    sendgrid, sendinblue, mandrill, postmark, dyn, maipeace,smtp2go
  """
  def validate_changeset(changeset, name),
    do: changeset |> validate_required(get_provider_fields(name))

  @doc """
  validates field is a valid url

  ## Examples
    iex> Ecto.Changeset.cast(%ZB.Account{}, %{"website" => "https://www.zipbooks.com"}, [:website])
    ...> |> validate_url(:website)
    ...> |> Map.get(:valid?)
    true

    iex> Ecto.Changeset.cast(%ZB.Account{}, %{"website" => "http://zipbooks.com/"}, [:website])
    ...> |> validate_url(:website)
    ...> |> Map.get(:valid?)
    true

    iex> Ecto.Changeset.cast(%ZB.Account{}, %{"website" => "zipbooks.com"}, [:website])
    ...> |> validate_url(:website)
    ...> |> Map.get(:valid?)
    false

    iex> Ecto.Changeset.cast(%ZB.Account{}, %{"website" => "https://zipbooks..com"}, [:website])
    ...> |> validate_url(:website)
    ...> |> Map.get(:valid?)
    false
  """
  def validate_url(changeset, field, opts \\ []) do
    validate_change(changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: nil} ->
          "is missing a scheme (e.g. https)"

        %URI{host: nil} ->
          "is missing a host"

        %URI{host: host} ->
          case :inet.gethostbyname(Kernel.to_charlist(host)) do
            {:ok, _} -> nil
            {:error, _} -> "invalid host"
          end
      end
      |> case do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end)
  end

  def get_provider_fields(nil), do: []

  def get_provider_fields(name) do
    case get_providers()[name] do
      %{fields: fields} -> fields
      _ -> []
    end
  end

  def get_providers(), do: @providers
end

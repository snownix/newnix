defmodule Newnix.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias Newnix.Projects.Invite
  alias Newnix.Projects.Project
  alias Newnix.Accounts.Identity
  alias Newnix.Projects.UserProject

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "users" do
    field :firstname, :string
    field :lastname, :string
    field :avatar, Newnix.Uploaders.AvatarUploader.Type

    field :phone, :string

    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :utc_datetime_usec

    # Newnix admin
    field :admin, :boolean, default: false

    # works only to retrive one user_project row
    has_one :role, UserProject

    has_many :invites, Invite, foreign_key: :user_id
    has_many :identities, Identity, foreign_key: :user_id
    many_to_many :projects, Project, join_through: UserProject

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    uniq_email? = Keyword.get(opts, :uniq_email, true)

    changeset =
      user
      |> cast(attrs, [:email, :password, :firstname, :lastname])
      |> validate_password(opts)

    if uniq_email?,
      do: validate_email(changeset, attrs),
      else: changeset |> validate_email_changeset(attrs)
  end

  def provider_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :firstname, :lastname])
    |> cast_assoc(:identities, with: &Identity.changeset/2, required: true)
    |> validate_required([:email])
    |> validate_email(attrs)
  end

  def login_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email_changeset(attrs)
    |> validate_password(opts)
  end

  def user_changeset(user, attrs) do
    user
    |> cast(attrs, [:firstname, :lastname, :phone])
    |> validate_length(:firstname, max: 100)
    |> validate_length(:lastname, max: 100)
  end

  def avatar_changeset(user, attrs) do
    user
    |> cast_attachments(attrs, [:avatar], allow_paths: true)
  end

  defp validate_email(changeset, attrs) do
    changeset
    |> validate_email_changeset(attrs)
    |> unsafe_validate_unique(:email, Newnix.Repo)
    |> unique_constraint(:email)
  end

  def validate_email_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email(attrs)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    user |> change(confirmed_at: Timex.now())
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Newnix.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "Wrong password")
    end
  end
end

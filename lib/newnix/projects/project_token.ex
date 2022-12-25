defmodule Newnix.Projects.ProjectToken do
  use Ecto.Schema
  import Ecto.Query

  alias Newnix.Accounts.User
  alias Newnix.Projects.Project
  alias Newnix.Projects.ProjectToken

  @timestamps_opts [type: :utc_datetime_usec]

  @hash_algorithm :sha256
  @rand_size 32

  @confirm_deletion_project 7

  schema "projects_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string

    belongs_to :user, User, type: :binary_id
    belongs_to :project, Project, type: :binary_id

    timestamps(updated_at: false)
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(project, user, context) do
    build_hashed_token(project, user, context, user.email)
  end

  defp build_hashed_token(project, user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %ProjectToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id,
       project_id: project.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  def verify_email_token_query(user, token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: project in assoc(token, :project),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == ^user.email,
            select: project

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("delete-confirm"), do: @confirm_deletion_project

  @doc """
  Returns the token struct for the given token value and context.
  """
  def token_and_context_query(token, context) do
    from ProjectToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  def user_and_contexts_query(user, :all) do
    from t in ProjectToken, where: t.user_id == ^user.id
  end

  def user_and_contexts_query(user, [_ | _] = contexts) do
    from t in ProjectToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end

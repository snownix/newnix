defmodule Newnix.Builder do
  @moduledoc """
  The Builder context.
  """

  import Ecto.Query
  alias Newnix.Repo
  alias Newnix.Builder.Form
  alias Newnix.Projects.Project
  alias Newnix.Campaigns.Campaign

  @doc """
  Returns the list of forms.

  ## Examples

      iex> list_forms()
      [%Menu{}, ...]

  """
  def list_forms(project = %Project{}, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(f in Form,
      where: f.project_id == ^project.id,
      order_by: {:desc, f.inserted_at},
      preload: [:campaign]
    )
    |> Repo.paginate(
      cursor_fields: [:inserted_at, :id],
      limit: Repo.secure_allowed_limit(limit)
    )
  end

  @doc """
  Gets a single form.

  Raises `Ecto.NoResultsError` if the Form does not exist.

  ## Examples

      iex> get_form!("aaaaa-bbbb-cccc-ddddd")
      %Form{}

      iex> get_form!("aaaaa-bbbb-cccc-ddddf")
      ** (Ecto.NoResultsError)

  """
  def get_form!(id), do: Repo.get!(Form, id)

  def get_form!(project = %Project{}, id) do
    Repo.one!(
      from f in Form,
        where: f.id == ^id and f.project_id == ^project.id
    )
    |> Repo.preload(:campaign)
  end

  @doc """
  preload campaign.

  ## Examples

      iex> list_campaign(form)
      %Form{ campaign: %Campaign{} }

  """
  def list_campaign(%Form{} = form) do
    Repo.preload(form, :campaign)
  end

  @doc """
  Creates a form.

  ## Examples

      iex> create_form(campaign, %{field: value})
      {:ok, %Form{}}

      iex> create_form(campaign, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_form(project = %Project{}, attrs \\ %{}) do
    %Form{}
    |> Form.changeset(attrs)
    |> Form.project_assoc(project)
    |> Repo.insert()
  end

  @doc """
  Updates a form.

  ## Examples

      iex> update_form(form, %{field: new_value})
      {:ok, %Form{}}

      iex> update_form(form, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_form(%Form{} = form, attrs) do
    form
    |> Form.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a form.

  ## Examples

      iex> delete_form(form)
      {:ok, %Form{}}

      iex> delete_form(form)
      {:error, %Ecto.Changeset{}}

  """
  def delete_form(%Form{} = form) do
    Repo.delete(form)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking form changes.

  ## Examples

      iex> change_form(form)
      %Ecto.Changeset{data: %Form{}}

  """
  def change_form(%Form{} = form, attrs \\ %{}) do
    Form.changeset(form, attrs)
  end
end

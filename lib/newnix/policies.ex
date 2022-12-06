defmodule Newnix.Policies do
  import Phoenix.LiveView, only: [put_flash: 3]

  alias Newnix.Builder.Form
  alias Newnix.Projects.Invite
  alias Newnix.Projects.Project
  alias Newnix.Campaigns.Campaign
  alias Newnix.Subscribers.Subscriber

  def roles() do
    [:admin, :manager, :user]
  end

  def permissions() do
    [
      %{collection: :form, actions: Form.policies()},
      %{collection: :campaign, actions: Campaign.policies()},
      %{collection: :subscriber, actions: Subscriber.policies()},
      %{collection: :invite, actions: Invite.policies()},
      %{collection: :project, actions: Project.policies()}
    ]
  end

  def contains_role?(roles, role) when is_list(roles) do
    Enum.member?(roles, role)
  end

  def can?(%{assigns: %{role: role}} = _socket, collection, action) do
    can?(role, collection, action)
  end

  def can?(%{role: role}, collection, action) do
    can?(role, collection, action)
  end

  def can?(:owner, _roles, _actions), do: true

  def can?(role, :project, action) do
    can_do?(role, Project.policies(), action)
  end

  def can?(role, :form, action) do
    can_do?(role, Form.policies(), action)
  end

  def can?(role, :invite, action) do
    can_do?(role, Invite.policies(), action)
  end

  def can?(role, :campaign, action) do
    can_do?(role, Campaign.policies(), action)
  end

  def can?(role, :subscriber, action) do
    can_do?(role, Subscriber.policies(), action)
  end

  def can?(_, _, _), do: false

  def can_do?(:owner, _collection, _actions), do: true

  def can_do?(role, %{} = map, action) do
    contains_role?(map[action] || [], role)
  end

  def can_do?(_, _, _), do: false

  def can_do!(%{assigns: %{role: role}} = socket, collection, action, callback) do
    can_do!(socket, role, collection, action, callback)
  end

  def can_do!(socket, role, collection, action, callback) do
    if can?(role, collection, action) do
      callback.(socket)
    else
      put_flash(socket, :error, "You dont have permission")
    end
  end
end

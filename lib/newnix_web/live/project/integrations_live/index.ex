defmodule NewnixWeb.Live.Project.IntegrationsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Projects
  alias Newnix.Projects.Integration

  def mount(_params, _session, %{assigns: %{project: project}} = socket) do
    if connected?(socket), do: Projects.subscribe(project.id)

    can_mount!(socket, :integration, :access, fn socket ->
      socket |> put_initial_assigns()
    end)
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:loading, true)
    |> assign(:empty_integrations, false)
    |> assign(:campaigns, %{
      metadata: nil,
      entries: []
    })
    |> assign(
      :integrations,
      Enum.map(
        Integration.detailed_providers(),
        &%{
          id: "loading",
          name: &1.name,
          type: &1.title,
          description: &1.description,
          items: []
        }
      )
    )
    |> fetch_records()
  end

  def handle_info({Projects, [_name, _event], _result}, socket) do
    {:noreply, socket |> fetch_records()}
  end

  def handle_info(:update, socket) do
    {:noreply, update_records(socket)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :create, _params) do
    socket
    |> assign(:integration, %Integration{
      status: :active
    })
    |> assign(:page_title, "New Invite")
  end

  defp apply_action(%{assigns: %{project: project}} = socket, :update, %{"id" => id}) do
    integration = Projects.get_integration!(project, id)

    socket
    |> assign(:integration, integration)
    |> assign(:page_title, "Edit Integration")
  end

  defp apply_action(socket, _, _) do
    socket
  end

  defp fetch_records(socket) do
    send(self(), :update)

    socket |> assign(:loading, true)
  end

  defp update_records(%{assigns: %{project: project, integrations: integrations}} = socket) do
    list_integrations = Projects.list_integrations(project)

    integrations =
      integrations
      |> Enum.map(fn provider ->
        %{provider | items: Enum.filter(list_integrations, &(&1.type == provider.name))}
      end)

    empty_integrations = Enum.empty?(integrations |> Enum.reject(&(&1.items === [])))

    socket
    |> assign(:empty_integrations, empty_integrations)
    |> assign(:integrations, integrations)
    |> assign(:loading, false)
  end
end

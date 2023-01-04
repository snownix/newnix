defmodule NewnixWeb.Live.Project.IntegrationsLive.FormComponent do
  use NewnixWeb, :live_component

  alias Newnix.Providers
  alias Plug.Projects
  alias Newnix.Projects
  alias Newnix.Projects.Integration

  @impl true
  def update(%{integration: integration} = assigns, socket) do
    changeset = Projects.change_integration(integration)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:status_options, Integration.status_options())
     |> put_apps_options()}
  end

  @impl true
  def handle_event("validate", %{"integration" => integration_params}, socket) do
    %{integration: integration} = socket.assigns

    changeset =
      integration
      |> Projects.change_integration(integration_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> clear_flash() |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"integration" => integration_params}, socket) do
    {:noreply, save_integration(socket, socket.assigns.action, integration_params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply,
     can_do!(socket, :integrations, :delete, fn %{assigns: %{project: project}} = socket ->
       form = Projects.get_integration!(project, id)
       {:ok, _} = Projects.delete_integration(form)

       socket |> push_patch(to: socket.assigns.return_to)
     end)}
  end

  defp save_integration(socket, :update, integration_params) do
    can_do!(socket, :integration, :update, fn %{assigns: %{integration: integration}} = socket ->
      case Projects.update_integration(integration, integration_params) do
        {:ok, _integration} ->
          socket
          |> put_flash(:info, "Integration updated successfully")
          |> push_patch(to: socket.assigns.return_to)

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, :changeset, changeset)
      end
    end)
  end

  defp save_integration(socket, :create, integration_params) do
    can_do!(
      socket,
      :integration,
      :create,
      fn %{
           assigns: %{
             current_user: user,
             project: project
           }
         } = socket ->
        case Projects.create_integration(project, user, integration_params) do
          {:ok, _integration} ->
            socket
            |> put_flash(:info, "Integration created successfully")
            |> push_patch(to: socket.assigns.return_to)

          {:error, %Ecto.Changeset{} = changeset} ->
            assign(socket, :changeset, changeset)
            |> put_changeset_errors(changeset)
        end
      end
    )
  end

  defp put_apps_options(socket) do
    options =
      Providers.get_active_prodivders()
      |> Map.to_list()
      |> Enum.map(fn {name, provider} ->
        {provider.title, name}
      end)

    socket |> assign(:options, options)
  end

  def input_config_active?(form, name) do
    Providers.input_config_required?(input_value(form, :type), name)
  end
end

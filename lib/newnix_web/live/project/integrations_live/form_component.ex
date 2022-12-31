defmodule NewnixWeb.Live.Project.IntegrationsLive.FormComponent do
  use NewnixWeb, :live_component

  alias Plug.Builder
  alias Newnix.Builder

  @impl true
  def update(
        %{project: _project} = assigns,
        socket
      ) do
    changeset = :integration

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> put_apps_options()}
  end

  @impl true
  def handle_event("validate", %{"integration" => integration_params}, socket) do
    changeset =
      socket.assigns.form
      |> Builder.change_form(integration_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"integration" => integration_params}, socket) do
    {:noreply, save_form(socket, socket.assigns.action, integration_params)}
  end

  defp save_form(socket, :update, integration_params) do
    can_do!(socket, :integration, :update, fn %{assigns: %{form: form}} = socket ->
      case Builder.update_form(form, integration_params) do
        {:ok, _form} ->
          socket
          |> put_flash(:info, "Form updated successfully")
          |> push_redirect(to: socket.assigns.return_to)

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, :changeset, changeset)
      end
    end)
  end

  defp save_form(socket, :create, integration_params) do
    can_do!(socket, :integration, :create, fn %{assigns: %{form: form}} = socket ->
      case Builder.create_form(form, integration_params) do
        {:ok, _form} ->
          socket
          |> put_flash(:info, "Form created successfully")
          |> push_redirect(to: socket.assigns.return_to)

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, :changeset, changeset)
      end
    end)
  end

  defp put_apps_options(socket) do
    options = [
      {"Mailchimp", :mailchimp},
      {"Mailgun", :mailgun},
      {"SendGrid", :sendgrid},
      {"SendinBlue", :sendinblue}
    ]

    socket |> assign(:options, options)
  end
end

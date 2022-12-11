defmodule NewnixWeb.Live.Project.FormsLive.FormComponent do
  use NewnixWeb, :live_component

  alias Plug.Builder
  alias Newnix.Builder
  alias Newnix.Builder.Form

  @impl true
  def update(%{form: form, campaigns: _campaigns, project: _project} = assigns, socket) do
    changeset = Builder.change_form(form)

    if connected?(socket), do: Builder.subscribe(form.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:done, false)
     |> assign(:advanced, false)
     |> assign(:changeset, changeset)
     |> assign(:status_options, Form.status_options())
     |> put_campaigns_options()}
  end

  @impl true
  def handle_event("done", _, socket) do
    {:noreply, socket |> assign(:done, true)}
  end

  @impl true
  def handle_event("open-advanced", _, socket) do
    {:noreply, socket |> assign(:advanced, !socket.assigns.advanced)}
  end

  @impl true
  def handle_event("validate", %{"form" => form_params}, socket) do
    changeset =
      socket.assigns.form
      |> Builder.change_form(form_params)
      |> Map.put(:action, :validate)

    {:noreply,
     assign(socket, :changeset, changeset)
     |> notify_dev()}
  end

  def handle_event("save", %{"form" => form_params}, socket) do
    {:noreply, save_form(socket, socket.assigns.action, form_params)}
  end

  defp save_form(socket, :update, form_params) do
    can_do!(socket, :form, :update, fn %{assigns: %{form: form}} = socket ->
      case Builder.update_form(form, form_params) do
        {:ok, _form} ->
          socket
          |> put_flash(:info, "Form updated successfully")
          |> push_redirect(to: socket.assigns.return_to)

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, :changeset, changeset)
      end
    end)
  end

  defp save_form(socket, :create, form_params) do
    can_do!(socket, :form, :create, fn %{assigns: %{form: form}} = socket ->
      case Builder.create_form(form, form_params) do
        {:ok, _form} ->
          socket
          |> put_flash(:info, "Form created successfully")
          |> push_redirect(to: socket.assigns.return_to)

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, :changeset, changeset)
      end
    end)
  end

  defp put_campaigns_options(%{assigns: assigns} = socket) do
    %{campaigns: campaigns} = assigns

    socket |> assign(:options, Enum.map(campaigns.entries, &{&1.name, &1.id}))
  end

  defp notify_dev(%{assigns: %{changeset: changeset, form: form}} = socket) do
    result = Map.merge(form, changeset.changes)

    Builder.notify_subscribers(:dev, result, [:form, :dev])

    socket
  end
end

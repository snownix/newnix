defmodule NewnixWeb.Live.Project.FormsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Builder
  alias Newnix.Campaigns
  alias Newnix.Builder.Form

  @skeleton_struct %Form{
    id: "",
    name: "loading",
    description: "loading",
    campaign_id: "",
    campaign: %{
      id: "",
      name: "loading"
    },
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:loading, true)
    |> assign(:campaigns, %{entries: []})
    |> assign(:forms, %{
      meta: nil,
      entries:
        skeleton_fake_data(
          @skeleton_struct,
          3
        )
    })
    |> fetch_campaigns()
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(:update, %{assigns: assigns} = socket) do
    %{project: project} = assigns

    forms = list_forms(project)

    {:noreply,
     socket
     |> assign(:forms, forms)
     |> assign(:loading, false)}
  end

  def handle_info({Builder, [:form, event], form}, socket) do
    {:noreply,
     case event do
       :deleted ->
         socket
         |> push_redirect(to: Routes.project_forms_index_path(socket, :index))

       _ ->
         socket |> assign(:form, form)
     end}
  end

  defp fetch_campaigns(%{assigns: %{project: project}} = socket) do
    socket |> assign(:campaigns, list_campaigns(project))
  end

  defp fetch_records(socket) do
    send(self(), :update)

    socket |> assign(:loading, true)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Forms")
    |> assign(:form, nil)
    |> fetch_records()
  end

  defp apply_action(%{assigns: %{project: project}} = socket, :new, _params) do
    form_draft_params = %{
      "name" => "#{Date.utc_today()} Draft",
      "css" =>
        "body {\n  --textColor: #252525;\n\n  --buttonTextColor: #fff;\n  --buttonBgColor: #0f121f;\n  --buttonBgHoverColor: #0f122f;\n\n  --inputBgColor: #25252505;\n  --inputTextColor: #0f121f;\n}",
      "firstname" => true,
      "lastname" => true
    }

    case Builder.create_form(project, form_draft_params) do
      {:ok, form} ->
        socket
        |> put_flash(:info, "Form created successfully")
        |> push_redirect(to: Routes.project_forms_index_path(socket, :edit, form.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp apply_action(%{assigns: %{project: project}} = socket, :edit, %{"id" => id}) do
    form = Builder.get_form!(project, id)

    socket
    |> assign(:page_title, "Edit Form")
    |> assign(:form, form)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: %{project: project}} = socket) do
    form = Builder.get_form!(project, id)
    {:ok, _} = Builder.delete_form(form)

    {:noreply, socket |> fetch_records()}
  end

  defp list_forms(project) do
    Builder.list_forms(project)
  end

  defp list_campaigns(project) do
    Campaigns.list_campaigns(project)
  end
end

defmodule NewnixWeb.Live.Project.FormsLive.Index do
  use NewnixWeb, :live_project

  # alias Newnix.Forms
  # alias Newnix.Forms.Form
  # alias Newnix.Campaigns

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  defp put_initial_assigns(socket) do
    socket
    |> assign(:loading, true)
    |> assign(:forms, %{
      meta: nil,
      entries:
        skeleton_fake_data(%{
          id: "loading",
          name: "Loading",
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        })
    })
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # @impl true
  # def handle_info(:update, %{assigns: assigns} = socket) do
  #   %{project: project} = assigns

  #   campaigns = list_campaigns(project)
  #   forms = list_forms(project)

  #   {:noreply,
  #    socket
  #    |> assign(:forms, forms)
  #    |> assign(:campaigns, campaigns)
  #    |> assign(:loading, false)}
  # end

  # defp fetch_records(socket) do
  #   send(self(), :update)

  #   socket |> assign(:loading, true)
  # end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Forms")
    |> assign(:form, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Form")
    |> assign(:form, %{id: nil})
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   form =
  #     Forms.get_form!(socket.assigns.project, id)
  #     |> Forms.fetch_campaigns()

  #   socket
  #   |> assign(:page_title, "Edit Form")
  #   |> assign(:form, form)
  # end

  # defp apply_action(socket, :show, %{"id" => id}) do
  #   form =
  #     Forms.get_form!(socket.assigns.project, id)
  #     |> Forms.fetch_campaigns()

  #   socket
  #   |> assign(:page_title, "Show Form")
  #   |> assign(:form, form)
  # end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   form = Forms.get_form!(socket.assigns.project, id)
  #   {:ok, _} = Forms.delete_form(form)

  #   {:noreply, assign(socket, :forms, list_forms(socket.assigns.project))}
  # end

  # defp list_forms(project) do
  #   Forms.list_forms(project)
  # end

  # defp list_campaigns(project) do
  #   Campaigns.list_campaigns(project)
  # end
end

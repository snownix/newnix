defmodule NewnixWeb.Live.Project.FormsLive.Index do
  use NewnixWeb, :live_project

  alias Newnix.Builder
  alias Newnix.Campaigns
  alias Newnix.Campaigns.Campaign
  alias Newnix.Builder.Form

  @skeleton_struct %Form{
    id: "",
    name: "loading",
    description: "loading",
    campaign_id: "",
    campaign: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("select-campaign", %{"campaign" => value}, socket) do
    socket =
      socket
      |> switch_campaign(value)

    send(self(), :update)

    {:noreply,
     socket
     |> assign(:loading, true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: %{project: project}} = socket) do
    form = Builder.get_form!(project, id)
    {:ok, _} = Builder.delete_form(form)

    {:noreply, socket |> fetch_records()}
  end

  @impl true
  def handle_info(:update, %{assigns: assigns} = socket) do
    %{project: project, campaigns_options: campaigns_options} = assigns

    campaigns_id = selected_campaigns(assigns) |> all_or_many_campaigns(campaigns_options)

    forms = Builder.list_forms(project, campaigns_id: campaigns_id)

    {:noreply,
     socket
     |> assign(:table, forms)
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

  defp put_initial_assigns(%{assigns: %{project_campaigns: project_campaigns}} = socket) do
    custom_params = get_connect_params(socket)

    socket
    |> assign(:loading, true)
    |> assign(:campaigns, %{entries: []})
    |> assign(
      :campaigns_options,
      Enum.map(project_campaigns, fn [id, value] ->
        %{label: value, value: id, selected: company_selected(id, custom_params)}
      end)
    )
    |> assign(:table, %{
      metadata: %{},
      entries:
        skeleton_fake_data(
          @skeleton_struct,
          3
        )
    })
    |> fetch_campaigns()
  end

  defp company_selected(id, %{"states" => %{"forms:campaign_id" => cid}}) when cid === id,
    do: true

  defp company_selected(_id, _), do: false

  defp fetch_campaigns(%{assigns: %{project: project}} = socket) do
    socket |> assign(:campaigns, Campaigns.list_campaigns(project))
  end

  defp fetch_records(socket) do
    send(self(), :update)

    socket |> assign(:loading, true)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:form, nil)
    |> assign(:page_title, "Listing Forms")
    |> apply_campaign_id(params)
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

  def apply_campaign_id(socket, %{"cam_id" => id}) do
    switch_campaign(socket, id)
  end

  def apply_campaign_id(socket, _), do: socket

  defp selected_campaigns(%{campaigns_options: campaigns_options}),
    do: Enum.filter(campaigns_options, & &1.selected) |> Enum.map(& &1.value)

  def all_or_many_campaigns([], items), do: items |> Enum.map(& &1.value)
  def all_or_many_campaigns(many, _items), do: many

  def current_status(campaign) do
    Campaign.campaign_status(campaign)
  end

  defp switch_campaign(%{assigns: assigns} = socket, value) do
    %{campaigns_options: campaigns_options} = assigns

    socket
    |> assign(
      :campaigns_options,
      campaigns_options
      |> Enum.map(fn c ->
        %{c | selected: c.value == value}
      end)
    )
  end
end

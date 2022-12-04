defmodule NewnixWeb.Live.Project.CampaignsLive.FormComponent do
  use NewnixWeb, :live_component

  alias Newnix.Campaigns
  alias Newnix.Campaigns.Campaign

  @impl true
  def update(%{campaign: campaign, project: _project} = assigns, socket) do
    changeset = Campaigns.change_campaign(campaign)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"campaign" => campaign_params}, socket) do
    changeset =
      socket.assigns.campaign
      |> Campaigns.change_campaign(campaign_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"campaign" => campaign_params}, socket) do
    %{assigns: %{action: action}} = socket

    {:noreply,
     can_do!(socket, :campaign, action, fn socket ->
       save_campaign(socket, action, campaign_params)
     end)}
  end

  defp save_campaign(socket, :update, campaign_params) do
    %{assigns: %{campaign: campaign, return_to: return_to}} = socket

    case Campaigns.update_campaign(campaign, campaign_params) do
      {:ok, _campaign} ->
        socket
        |> put_flash(:info, "Campaign updated successfully")
        |> push_redirect(to: return_to)

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, :changeset, changeset)
    end
  end

  defp save_campaign(socket, :create, campaign_params) do
    %{assigns: %{project: project, return_to: return_to}} = socket

    case Campaigns.create_campaign(project, campaign_params) do
      {:ok, _campaign} ->
        socket
        |> put_flash(:info, "Campaign created successfully")
        |> push_redirect(to: return_to)

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  def status(changeset) do
    Campaign.campaign_status(changeset)
  end
end

defmodule NewnixWeb.Live.Form.FormLive.Index do
  use NewnixWeb, :live_form

  alias Newnix.Campaigns.Campaign
  alias Newnix.Builder
  alias Newnix.Subscribers
  alias Newnix.Subscribers.Subscriber

  def mount(_params, _session, socket) do
    {:ok, socket |> put_initial_assigns()}
  end

  def handle_params(_params, _url, %{assigns: %{form: form, live_action: live_action}} = socket) do
    {:noreply, apply_action(socket, live_action, form)}
  end

  def handle_info({Builder, [:form, event], form}, socket) do
    {:noreply,
     case event do
       :deleted ->
         socket |> assign(:form, nil)

       _ ->
         socket |> assign(:form, form)
     end}
  end

  def handle_event("validate", %{"subscriber" => subscriber_params}, socket) do
    %{assigns: %{form: form}} = socket

    opts = [firstname: form.firstname, lastname: form.lastname]

    changeset =
      %Subscriber{}
      |> Subscribers.change_subscriber(subscriber_params, opts)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "save",
        %{"subscriber" => subscriber_params},
        %{assigns: %{live_action: live_action}} = socket
      ) do
    save_subscriber(socket, live_action, subscriber_params)
  end

  def get_form_value(value, default \\ nil) do
    value || default
  end

  def campaign_status(%{campaign: campaign}) do
    Campaign.campaign_status(campaign)
  end

  defp apply_action(socket, :index, form) do
    if connected?(socket), do: Newnix.Builder.subscribe(form.id)
    socket
  end

  defp apply_action(socket, :dev, form) do
    if connected?(socket), do: Newnix.Builder.subscribe(:dev, form.id)
    socket |> assign(:dev, true)
  end

  defp put_initial_assigns(%{assigns: %{form: form}} = socket) do
    opts = [firstname: form.firstname, lastname: form.lastname]

    socket
    |> assign(
      :changeset,
      Subscribers.change_subscriber(%Subscriber{}, %{}, opts)
    )
    |> assign(:dev, false)
    |> assign(:success, false)
  end

  defp put_success_message(socket) do
    socket |> assign(:success, true)
  end

  defp save_subscriber(socket, :dev, _subscriber_params) do
    {:noreply, put_success_message(socket)}
  end

  defp save_subscriber(%{assigns: %{form: form}} = socket, :index, subscriber_params) do
    case Subscribers.create_subscriber(form.campaign, subscriber_params) do
      {:ok, _subscriber} ->
        {:noreply, put_success_message(socket)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

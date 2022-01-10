defmodule ClusteringWeb.MainPageLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    app_var = ConCache.get_or_store(:app_cache, :key, fn ->
      0
    end)

    :ok = PubSub.subscribe(Clustering.PubSub, "internal")

    socket = socket
    |> assign(:state_var, 0)
    |> assign(:app_var, app_var)
    |> assign(:pubsub_count, 0)
    |> assign(:nodes, Node.list())

    {:ok, socket}
  end

  @impl true
  def handle_info(:nodes_updated, socket) do
    socket = socket
      |> assign(:nodes, Node.list())

    {:noreply, socket}
  end

  @impl true
  def handle_event("state_var:up", _event, socket) do
    socket = socket
      |> assign(:state_var, socket.assigns[:state_var] + 1)

    {:noreply, socket}
  end

  def handle_event("state_var:down", _event, socket) do
    socket = socket
      |> assign(:state_var, socket.assigns[:state_var] - 1)

    {:noreply, socket}
  end

  def handle_event("app_var:up", _event, socket) do
    new_value = ConCache.get(:app_cache, :key) + 1
    ConCache.put(:app_cache, :key, new_value)

    socket = socket
      |> assign(:app_var, new_value)

    {:noreply, socket}
  end

  def handle_event("app_var:down", _event, socket) do
    new_value = ConCache.get(:app_cache, :key) - 1
    ConCache.put(:app_cache, :key, new_value)

    socket = socket
      |> assign(:app_var, new_value)

    {:noreply, socket}
  end
end

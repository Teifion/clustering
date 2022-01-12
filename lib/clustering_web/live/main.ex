defmodule ClusteringWeb.MainPageLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub
  require Logger

  @impl true
  def mount(params, _session, socket) do
    app_var = ConCache.get_or_store(:app_cache, :key, fn ->
      0
    end)

    :ok = PubSub.subscribe(Clustering.PubSub, "internal")

    page_title = Node.self()
      |> to_string
      |> String.split("@")
      |> Enum.at(1)

    socket = socket
    |> assign(:state_var, 0)
    |> assign(:app_var, app_var)
    |> assign(:pubsub_count, 0)
    |> assign(:nodes, Node.list())
    |> assign(:page_title, page_title)
    |> assign(:node_count, Enum.count(Application.get_env(:clustering, Clustering)[:ips]))
    |> assign(:id, nil)

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _opts, socket) do
    state_var = ConCache.get_or_store(:app_cache, id, fn ->
      0
    end)

    {:noreply,
      socket
      |> assign(:state_var, state_var)
      |> assign(:id, id)
    }
  end

  def handle_params(_, _opts, socket) do
    id = :rand.uniform(8999) + 1000

    {:noreply,
      socket
      |> redirect(to: "/live/#{id}")
    }
  end

  @impl true
  def handle_info(:nodes_updated, socket) do
    socket = socket
      |> assign(:nodes, Node.list())

    {:noreply, socket}
  end

  @impl true
  def handle_event("transfer:" <> id_str, _event, socket) do
    id_int = String.to_integer(id_str)

    ip = Application.get_env(:clustering, Clustering)[:ips]
    |> Enum.at(id_int)

    {:noreply,
      socket
      |> redirect(external: "http://#{ip}:8888/live/#{socket.assigns[:id]}")
    }
  end


  def handle_event("transfer", _event, socket) do
    ip = Application.get_env(:clustering, Clustering)[:ips]
    |> Enum.random()

    {:noreply,
      socket
      |> redirect(external: "http://#{ip}:8888/live/#{socket.assigns[:id]}")
    }
  end

  def handle_event("state_var:up", _event, socket) do
    new_value = ConCache.get(:app_cache, socket.assigns[:id]) + 1
    ConCache.put(:app_cache, socket.assigns[:id], new_value)

    socket = socket
      |> assign(:state_var, new_value)

    {:noreply, socket}
  end

  def handle_event("state_var:down", _event, socket) do
    new_value = ConCache.get(:app_cache, socket.assigns[:id]) - 1
    ConCache.put(:app_cache, socket.assigns[:id], new_value)

    socket = socket
      |> assign(:state_var, new_value)

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

defmodule ClusteringWeb.MainPageLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    page_title = Node.self()
      |> to_string
      |> String.split("@")
      |> Enum.at(1)

    socket = socket
      |> assign(:node_var, 0)
      |> assign(:shared_var, 0)
      |> assign(:pubsub_count, 0)
      |> assign(:nodes, Node.list())
      |> assign(:page_title, page_title)
      |> assign(:node_count, Enum.count(Application.get_env(:clustering, Clustering)[:ips]))
      |> assign(:id, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _opts, socket) do
    node_var = ConCache.get_or_store(:node_cache, id, fn -> 0 end)
    shared_var = ConCache.get(:shared_cache, id) || 0

    :ok = PubSub.subscribe(Clustering.PubSub, "ets_updates:shared_cache/#{id}")

    {:noreply,
      socket
      |> assign(:node_var, node_var)
      |> assign(:shared_var, shared_var)
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
  def handle_info({:ets_update, :update_value, key, value}, %{assigns: %{id: id}} = socket) do
    if key == id do
      {:noreply,
        socket
          |> assign(:shared_var, value)
      }
    else
      {:noreply, socket}
    end
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

  def handle_event("node_var:up", _event, %{assigns: %{id: id, node_var: node_var}} = socket) do
    new_value = node_var + 1
    ConCache.put(:node_cache, id, new_value)

    socket = socket
      |> assign(:node_var, new_value)

    {:noreply, socket}
  end

  def handle_event("node_var:down", _event, %{assigns: %{id: id, node_var: node_var}} = socket) do
    new_value = node_var - 1
    ConCache.put(:node_cache, id, new_value)

    socket = socket
      |> assign(:node_var, new_value)

    {:noreply, socket}
  end

  def handle_event("shared_var:up", _event, %{assigns: %{id: id, shared_var: shared_var}} = socket) do
    new_value = shared_var + 1
    PubSub.broadcast(
      Clustering.PubSub,
      "ets_updates",
      {:update_value, :shared_cache, id, new_value}
    )

    {:noreply, socket}
  end

  def handle_event("shared_var:down", _event, %{assigns: %{id: id, shared_var: shared_var}} = socket) do
    new_value = shared_var - 1
    PubSub.broadcast(
      Clustering.PubSub,
      "ets_updates",
      {:update_value, :shared_cache, id, new_value}
    )

    {:noreply, socket}
  end
end

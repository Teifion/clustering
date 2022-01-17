defmodule Clustering.DbServer do
  @moduledoc false
  use GenServer
  alias Phoenix.PubSub
  require Logger

  @spec start_link(List.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  def handle_info({:mnesia, :node_added}, state) do
    :mnesia.change_config(:extra_db_nodes, Node.list())

    {:noreply, state}
  end

  def handle_info({:mnesia, :all_nodes_added}, state) do
    Logger.info("All nodes added")
    :mnesia.change_config(:extra_db_nodes, Node.list())
    {:noreply, state}
  end

  def handle_info({:mnesia, :start}, state) do
    Logger.info("Starting db_server")

    # nodes = [Node.self() | Node.list]
    # :mnesia.info

    # PubSub.broadcast(
    #   Clustering.PubSub,
    #   "internal",
    #   {:stop_amnesia, Node.self()}
    # )

    Amnesia.Schema.create([Node.self()])
    Amnesia.start

    # :mnesia.change_config(:extra_db_nodes, Node.list())

    # PubSub.broadcast(
    #   Clustering.PubSub,
    #   "internal",
    #   {:start_amnesia, Node.self()}
    # )

    # PubSub.broadcast(
    #   Clustering.PubSub,
    #   "internal",
    #   {:db_started, node()}
    # )

    {:noreply, state}
  end

  def handle_info(:nodes_updated, state), do: {:noreply, state}

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  @spec init(Map.t()) :: {:ok, Map.t()}
  def init(_opts) do
    :ok = PubSub.subscribe(Clustering.PubSub, "mnesia")
    {:ok, %{}}
  end
end

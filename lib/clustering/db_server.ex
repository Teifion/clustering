defmodule Clustering.DbServer do
  @moduledoc false
  use GenServer
  alias Phoenix.PubSub
  require Logger

  @spec start_link(List.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  def handle_info({:nodes_added, from}, state) do
    Logger.info("Starting db_server from #{from}")

    {:noreply, state}
  end

  def handle_info(:nodes_updated, state), do: {:noreply, state}

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  @spec init(Map.t()) :: {:ok, Map.t()}
  def init(_opts) do
    :ok = PubSub.subscribe(Clustering.PubSub, "internal")
    {:ok, %{}}
  end
end

defmodule Clustering.DbServer do
  @moduledoc """
  Genserver that makes use of the cachex library for a datastore
  """
  use GenServer
  alias Phoenix.PubSub
  require Logger

  @spec start_link(List.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  def handle_info(:start_caches, state) do
    DynamicSupervisor.start_child(Clustering.DynamicCacheSupervisor, {
      Cachex,
      name: :store_a
    })

    DynamicSupervisor.start_child(Clustering.DynamicCacheSupervisor, {
      Cachex,
      name: :store_b
    })

    {:noreply, state}
  end

  def x do
    Cachex.put(:store_a, "key", "value")
    Cachex.get!(:store_a, "key")
    Cachex.get!(:store_b, "key")
  end

  @spec init(Map.t()) :: {:ok, Map.t()}
  def init(_opts) do
    :timer.send_after(100, :start_caches)

    :ok = PubSub.subscribe(Clustering.PubSub, "cachex")
    {:ok, %{}}
  end
end

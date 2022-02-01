defmodule Clustering.DbServer do
  @moduledoc """
  Process for updating the ets tables we use as an in-memory store
  """
  use GenServer
  alias Phoenix.PubSub
  require Logger

  @spec start_link(List.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  def handle_info({:update_value, table, key, value}, state) do
    ConCache.put(table, key, value)

    PubSub.broadcast(
      Clustering.PubSub,
      "ets_updates:shared_cache/#{key}",
      {:ets_update, :update_value, key, value}
    )

    {:noreply, state}
  end

  @spec init(Map.t()) :: {:ok, Map.t()}
  def init(_opts) do
    :ok = PubSub.subscribe(Clustering.PubSub, "ets_updates")
    {:ok, %{}}
  end
end

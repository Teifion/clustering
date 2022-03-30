defmodule Clustering.ValueServer do
  use GenServer
  alias Phoenix.PubSub
  require Logger

  def start_link(key) do
    case GenServer.start_link(__MODULE__, [key: key], name: via_tuple(key)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("already started at #{inspect(pid)}, returning :ignore")
        :ignore
    end
  end

  defp via_tuple(key) do
    {:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:#{key}"}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, Map.put(state, :node, Node.self()), state}
  end

  def handle_call(:get_value, _from, state) do
    {:reply, state.value, state}
  end

  def handle_call(:node, _from, state) do
    {:reply, Node.self(), state}
  end

  @impl true
  def handle_info({:put, value}, state) do
    {:noreply, %{state | value: value}}
  end

  def handle_info({:update_value, _table, key, value}, state) do
    new_state = if key == state.key do
      %{state | value: value}
    else
      state
    end

    {:noreply, new_state}
  end

  @impl true
  def init(opts) do
    key = opts[:key]

    :ok = PubSub.subscribe(Clustering.PubSub, "ets_updates")

    {:ok, %{
      key: key,
      value: nil
    }}
  end

  def child_spec(opts) do
    key = opts[:key]

    %{
      id: "ValueServer:#{key}",
      start: {__MODULE__, :start_link, [key]},
      shutdown: 10_000,
      restart: :transient
    }
  end
end

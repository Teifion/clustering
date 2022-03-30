defmodule Clustering.CoordinatorServer do
  use GenServer
  alias Phoenix.PubSub
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_value, _from, state) do
    {:reply, nil, state}
  end

  def handle_call(:node, _from, state) do
    {:reply, Node.self(), state}
  end

  # @impl true
  # def handle_info({:put, value}, state) do
  #   {:noreply, %{state | value: value}}
  # end

  @impl true
  def init(_) do
    # Registry.register(
    #   Clustering.ValueRegistry,
    #   "CoordinatorServer",
    #   :coordinator
    # )

    {:ok, %{

    }}
  end
end

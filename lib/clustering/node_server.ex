defmodule Clustering.NodeServer do
  @moduledoc false
  use GenServer
  alias Phoenix.PubSub
  require Logger

  @expected_nodes ~w(clustering@cbox1 clustering@cbox2 clustering@cbox3 clustering@cbox4)a

  @spec start_link(List.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  def handle_info(:tick, state) do
    existing = Node.list()

    @expected_nodes
    |> Enum.filter(fn n -> n != Node.self() end)
    |> Enum.map(fn n ->
      if not Enum.member?(existing, n) do
        case Node.ping(n) do
          :ping ->
            case Node.connect(n) do
              true ->
                PubSub.local_broadcast(
                  Clustering.PubSub,
                  "mnesia",
                  {:mnesia, :node_added}
                )
                # Logger.info("Connected to #{n}")
              _v ->
                # Logger.info("Not got node #{n}, unable to connect (got #{v})")
                :ok
            end
          _ ->
            :ok
        end
      end
    end)

    new_state = if not state.all_nodes_added do
      has_remaining_nodes = @expected_nodes
      |> Enum.filter(fn n -> n != Node.self() and not Enum.member?(existing, n) end)
      |> Enum.empty?

      if not has_remaining_nodes do
        PubSub.local_broadcast(
          Clustering.PubSub,
          "mnesia",
          {:mnesia, :all_nodes_added}
        )

        %{state | all_nodes_added: true}
      else
        state
      end
    else
      state
    end

    {:noreply, new_state}
  end

  @spec init(Map.t()) :: {:ok, Map.t()}
  def init(_opts) do
    :timer.send_interval(1_000, :tick)
    boss_node = hd(@expected_nodes) == Node.self()

    if boss_node do
      PubSub.local_broadcast(
        Clustering.PubSub,
        "mnesia",
        {:mnesia, :start}
      )
    end

    {:ok, %{
      all_nodes_added: false,
      i_am_boss: boss_node == Node.self()
    }}
  end
end

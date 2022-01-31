defmodule Clustering.NodeServer do
  @moduledoc """
  Genserver responsible for connecting to the other servers
  """

  use GenServer
  alias Phoenix.PubSub
  require Logger

  @expected_nodes ~w(clustering@cbox1 clustering@cbox2 clustering@cbox3 clustering@cbox4)a

  def node_list do
    @expected_nodes
  end

  @spec start_link(List.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  def handle_info(:tick, state) do
    existing = Node.list()

    missing_nodes = @expected_nodes
      |> Enum.filter(fn n -> n != Node.self() and not Enum.member?(existing, n) end)

    missing_nodes
      |> Enum.map(&add_node/1)

    new_state = if not state.all_nodes_added do
      # Recalculate missing nodes since we just tried adding new ones
      missing_nodes = @expected_nodes
        |> Enum.filter(fn n -> n != Node.self() and not Enum.member?(existing, n) end)

      if Enum.empty?(missing_nodes) do
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

  defp add_node(n) do
    case Node.ping(n) do
      :pong ->
        case Node.connect(n) do
          true ->
            Logger.info("Node added: #{n}")
            PubSub.local_broadcast(
              Clustering.PubSub,
              "mnesia",
              {:mnesia, :node_added}
            )
          _v ->
            :ok
        end
      :pang ->
        :ok
    end
  end

  @spec init(Map.t()) :: {:ok, Map.t()}
  def init(_opts) do
    :timer.send_interval(3_000, :tick)
    boss_node = hd(@expected_nodes |> Enum.reverse) == Node.self()

    # spawn(fn ->
    #   :timer.sleep(500)
    #   PubSub.local_broadcast(
    #     Clustering.PubSub,
    #     "mnesia",
    #     {:mnesia, :create}
    #   )
    # end)

    if boss_node do
      spawn(fn ->
        :timer.sleep(2500)
        PubSub.local_broadcast(
          Clustering.PubSub,
          "mnesia",
          {:mnesia, :start}
        )
      end)
    end

    {:ok, %{
      all_nodes_added: false,
      i_am_boss: boss_node
    }}
  end
end

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
        case Node.connect(n) do
          true ->
            :ok
            # Logger.info("Connected to #{n}")
          _v ->
            # Logger.info("Not got node #{n}, unable to connect (got #{v})")
            :ok
        end
      end
    end)

    PubSub.broadcast(
      Clustering.PubSub,
      "internal",
      :nodes_updated
    )

    new_state = if Enum.count(@expected_nodes) == Enum.count([node() | Node.list()]) do
      if state.nodes_added do
        state
      else
        PubSub.broadcast(
          Clustering.PubSub,
          "internal",
          {:nodes_added, node()}
        )
        %{state | nodes_added: true}
      end
    else
      state
    end

    {:noreply, new_state}
  end

  @spec init(Map.t()) :: {:ok, Map.t()}
  def init(_opts) do
    :timer.send_interval(1_000, :tick)
    {:ok, %{
      nodes_added: false
    }}
  end
end

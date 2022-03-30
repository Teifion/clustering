defmodule Clustering do
  require Logger
  alias Phoenix.PubSub
  @moduledoc """
  Clustering keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # def start_value_server(key) do
  #   result =
      # DynamicSupervisor.start_child(Clustering.ValueSupervisor, {
      #   Clustering.ValueServer,
      #   name: via_tuple("ValueServer:#{key}", key),
      #   data: %{
      #     key: key,
      #   }
      # })

  #   Logger.info(Kernel.inspect result)
  # end

  def start_value_server(key) do
    DynamicSupervisor.start_child(Clustering.ValueSupervisor, {
      Clustering.ValueServer,
      name: "ValueServer:123",
      data: %{
        key: "123",
      }
    })

    Horde.DynamicSupervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: key]})
  end

  def register_value_server(key) do
    {:ok, _pid} = Supervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: key]})
  end

  def start_value_server(key) do
    # {:ok, pid} = Swarm.register_name("ValueServer:#{123}", Clustering, :register_value_server, ["ValueServer:#{123}"])

    name = "ValueServer:#{key}"
    {:ok, pid} = Swarm.register_name(name, Clustering, :register_value_server, [name])

    Swarm.join(:foo, pid)
  end

  # defp via_tuple(key) do
  #   {:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:#{key}"}}
  # end

  def values() do
    # See contents of registry
    pids = Registry.select(Clustering.ValueRegistry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])

    pids
    |> Enum.each(fn {name, pid, id} ->
      node = GenServer.call(pid, :node)
      value = GenServer.call(pid, :get_value)
      Logger.info Kernel.inspect({name, pid, id, value, node})
    end)
  end

  def set_value(key, value) do
    PubSub.broadcast(
      Clustering.PubSub,
      "ets_updates",
      {:update_value, :shared_cache, key, value}
    )
  end
end

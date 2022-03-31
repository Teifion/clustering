defmodule Clustering.ValueSupervisor do
  @moduledoc """
  This is the supervisor for the worker processes you wish to distribute
  across the cluster, Swarm is primarily designed around the use case
  where you are dynamically creating many workers in response to events. It
  works with other use cases as well, but that's the ideal use case.
  """
  use Swarm.DynamicSupervisor

  def start_link() do
    Swarm.DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Swarm.DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Registers a new worker, and creates the worker process

  Notice that there is a required field `id` in child_spec. It's used for registering
  name of process in Swarm. You no longer have to call `Swarm.register_name/5`
  explicitly anymore.
  """
  def start_child(module, opts) do
    # spec = Supervisor.child_spec(MyApp.Worker, id: name, start: {MyApp.Worker, :start_link, [name]})
    spec = module.child_spec(opts)
    Swarm.DynamicSupervisor.start_child(__MODULE__, spec)
  end
end


# key = "123"
# # spec = Supervisor.child_spec(Clustering.ValueServer, id: "ValueServer:#{key}", start: {Clustering.ValueServer, :start_link, ["ValueServer:#{key}"]})
# spec = Clustering.ValueServer.child_spec([key: "123", value: 123])
# Swarm.DynamicSupervisor.start_child(__MODULE__, spec)

# defmodule Clustering.ValueSupervisor do
#   use DynamicSupervisor

#   def start_link(init_args) do
#     DynamicSupervisor.start_link(__MODULE__, [init_args], name: __MODULE__)
#   end

#   # def start_child(child_args) do
#   #   child_spec = %{
#   #     id: /capitalize,
#   #     start: {/capitalize, :start_link, [child_args]},
#   #     restart: :transient,
#   #     shutdown: :brutal_kill,
#   #     type: :worker,
#   #     modules: [/capitalize],
#   #   }

#   #   DynamicSupervisor.start_child(__MODULE__, child_spec)
#   # end

#   def init([init_args]) do
#     DynamicSupervisor.init(strategy: :one_for_one)
#   end

#   @doc """
#   Registers a new worker, and creates the worker process
#   """
#   def register(worker_name) do
#     {:ok, _pid} = Supervisor.start_child(__MODULE__, [worker_name])
#   end
# end

defmodule Clustering.Supervisor do
  @moduledoc """
  This is the supervisor for the worker processes you wish to distribute
  across the cluster, Swarm is primarily designed around the use case
  where you are dynamically creating many workers in response to events. It
  works with other use cases as well, but that's the ideal use case.
  """
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Clustering.Worker, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Registers a new worker, and creates the worker process
  """
  def register(worker_name) do
    {:ok, _pid} = Supervisor.start_child(__MODULE__, [worker_name])
  end
end

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

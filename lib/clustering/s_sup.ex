defmodule Clustering.SwarmSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, name, name: name)
  end

  def init(name) do
    children = [
      {Clustering.SwarmWorker, [name]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

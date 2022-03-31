# Swarm
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "121", value: 121])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "122", value: 122])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "123", value: 123])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "124", value: 124])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "125", value: 125])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "126", value: 126])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "127", value: 127])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "128", value: 128])
Clustering.ValueSupervisor.start_child(Clustering.ValueServer, [key: "129", value: 129])

:sys.get_state(Swarm.Tracker)

pids = Registry.select(Swarm.Registry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])

pids |>
Enum.map(fn {name, pid, id} ->
  node = GenServer.call(pid, :node)
  value = GenServer.call(pid, :get_value)
  {name, pid, id, value, node}
end)

GenServer.call({:via, :swarm, "ValueServer:121"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:122"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:123"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:124"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:125"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:126"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:127"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:128"}, :get_state)
GenServer.call({:via, :swarm, "ValueServer:129"}, :get_state)

GenServer.cast({:via, :swarm, "ValueServer:121"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:122"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:123"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:124"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:125"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:126"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:127"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:128"}, {:put, 10})
GenServer.cast({:via, :swarm, "ValueServer:129"}, {:put, 10})

At this stage restarting a node doesn't seem to restart the process



Supervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: "1"]})
Supervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: "2"]})

name = "123"
Swarm.register_name("ValueServer:123", Clustering, :register_value_server, ["123"])
Swarm.register_name("ValueServer:124", Clustering, :register_value_server, ["124"])

Swarm.join(:foo, pid)

:sys.get_state(Swarm.Tracker)



# Using Horde
Clustering.start_value_server("123")

via = {:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}
GenServer.call({:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}, :get_state)




-- OLD
# See contents of registry
pids = Registry.select(Clustering.ValueRegistry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])

pids |>
Enum.map(fn {name, pid, id} ->
  node = GenServer.call(pid, :node)
  value = GenServer.call(pid, :get_value)
  {name, pid, id, value, node}
end)

Clustering.start_value_server("123")

key = "123"
name = {:via, Registry, {Clustering.ValueRegistry, "ValueServer:123"}}
Agent.start_link(fn -> 0 end, name: name)
Registry.lookup(Clustering.ValueRegistry, "ValueServer:123")


name = "ValueServer:123"
{:ok, pid} = Swarm.register_name(name, Clustering.ValueSupervisor, :register, [key: "123"])

# :sys.get_state(Swarm.Tracker)

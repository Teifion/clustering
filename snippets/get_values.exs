# Swarm
Supervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: "124"]})
Supervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: "125"]})


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

Clustering.values()

Clustering.start_value_server(key: "123", value: 123)
Clustering.start_value_server(key: "456", value: 987)

# Calling a server that's not running will yield this
GenServer.call({:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}, :get_state)
# ** (exit) exited in: GenServer.call({:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}, :get_state, 5000)
#     ** (EXIT) no process: the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started
#     (elixir 1.13.2) lib/gen_server.ex:1019: GenServer.call/3

# Start server with
Horde.DynamicSupervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: "123"]})
Horde.DynamicSupervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: "124"]})
# {:ok, #PID<0.1627.0>}

# Now it's running you can get the state with
GenServer.call({:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}, :get_state)
# %{key: "123", node: :clustering@cbox1, value: nil}

# Calling it from a different box should yield an identical result
Horde.Registry.select(Clustering.ValueRegistry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])


Horde.Registry.select(Clustering.ValueRegistry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}]) |>
Enum.map(fn {_key, pid, _value} ->
  GenServer.call(pid, :get_state)
end)


Clustering.start_value_server("123")
Clustering.start_value_server("124")

Horde.DynamicSupervisor.start_child(Clustering.ValueSupervisor, {Clustering.ValueServer, [key: key]})

via = {:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}
GenServer.call({:via, Horde.Registry, via}, :get_state)


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

:sys.get_state(Swarm.Tracker)

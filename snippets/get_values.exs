Clustering.values()

Clustering.start_value_server(key: "123", value: 123)
Clustering.start_value_server(key: "456", value: 987)


GenServer.call({:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}, :get_state)


GenServer.cast({:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:123"}}, {:put, 111})
GenServer.cast({:via, Horde.Registry, {Clustering.ValueRegistry, "ValueServer:456"}}, {:put, 444})

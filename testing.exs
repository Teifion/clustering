alias Phoenix.PubSub

nodes = [Node.self() | Node.list()]
:mnesia.info

PubSub.broadcast(
  Clustering.PubSub,
  "internal",
  :stop_amnesia
)
:mnesia.info

Amnesia.Schema.create(nodes)

PubSub.broadcast(
  Clustering.PubSub,
  "internal",
  :start_amnesia
)

Amnesia.Schema.destroy(nodes)
:mnesia.info

Amnesia.Schema.create(nodes)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

:mnesia.change_config(:extra_db_nodes, Node.list())

# Copies the tables across
[{Tb, mnesia:add_table_copy(Tb, node(), Type)} || {Tb, [{'a@node', Type}]} <- [{T, mnesia:table_info(T, where_to_commit)} || T <- mnesia:system_info(tables)]].

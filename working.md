https://hexdocs.pm/elixir/Node.html
https://stackoverflow.com/questions/17351882/how-to-connect-two-elixir-nodes-via-local-network
```
Interactive Elixir (1.12.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(clustering@cbox1)1> Node.list()
[]
iex(clustering@cbox1)2> Node.self()
:clustering@cbox1
iex(clustering@cbox1)3> Node.get_cookie()
:"PI2XBTYCAFQNCNWX25CEHVJVY5NHSCRITI5TYUU5FC76IRLZBFXQ===="
iex(clustering@cbox1)4> Node.connect(:clustering@cbox2)
true
iex(clustering@cbox1)5> 
```

Currently just found that Phoenix pubsubs go to all nodes, trying to get the database to be created and read at startup using a genserver.

https://medium.com/@jmerriweather/elixir-phoenix-amnesia-multi-node-451e8565da1d
https://github.com/meh/amnesia/blob/master/lib/mix/amnesia.create.ex
https://github.com/meh/amnesia

Other links for later
https://github.com/bitwalker/libcluster
https://dashbit.co/blog/you-may-not-need-redis-with-elixir


nodes = [node | Node.list]
Amnesia.Schema.create(nodes)
Amnesia.start
Database.create!(disk: nodes)
https://github.com/meh/amnesia/blob/master/lib/mix/amnesia.create.ex

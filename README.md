# Installation and usage instructions
## Setup + Install
Setup 4 virtual machine boxes running centos 7. Currently you will need to find-replace the IP addresses used here, later I want to make them configurable.
```
chmod -R +x bin/
bin/setup
bin/install
```

## Usage
```
bin/deploy
mix phx.server
# open http://localhost:4000/
```

## Interactive
```
bin/ssh1
capp remote
# Should now have an elixir shell into the running app
```

# Sites/tutorials to use
https://benjamintan.io/blog/2014/05/25/connecting-elixir-nodes-on-the-same-lan/
https://zohaib.me/setting-up-elixir-cluster/
https://elixirschool.com/en/lessons/advanced/otp-distribution/
https://medium.com/@jmerriweather/elixir-phoenix-amnesia-multi-node-451e8565da1d


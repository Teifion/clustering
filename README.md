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

# Stuff I did that I've not saved properly
update /etc/hosts - https://medium.com/@priyantha.getc/elixir-how-to-invoke-remote-functions-d961985f3862

echo '192.168.1.104       cbox1' >> /etc/hosts
echo '192.168.1.183       cbox2' >> /etc/hosts
echo '192.168.1.198       cbox3' >> /etc/hosts
echo '192.168.1.174       cbox4' >> /etc/hosts

# Sites/tutorials to use for setup
https://benjamintan.io/blog/2014/05/25/connecting-elixir-nodes-on-the-same-lan/
https://zohaib.me/setting-up-elixir-cluster/
https://elixirschool.com/en/lessons/advanced/otp-distribution/
https://medium.com/@jmerriweather/elixir-phoenix-amnesia-multi-node-451e8565da1d

# Sites/tutorials post setup
https://dashbit.co/blog/you-may-not-need-redis-with-elixir - https://github.com/bitwalker/libcluster


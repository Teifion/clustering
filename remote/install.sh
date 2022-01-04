#!/usr/bin/env bash
# First we add some extra repos
yum install epel-release -y

yum update -y
yum -y install htop git-core ca-certificates vim curl vnstat net-tools wget epel-release snapd
yum -y upgrade
yum -y autoremove
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap

# Set a new hostname
hostnamectl set-hostname $(( $RANDOM % 8999 + 1000 ))

### Nginx
yum install -y nginx
chmod +r /var/log/nginx
systemctl start nginx

### Nginx config
> /etc/nginx/nginx.conf
cat >> /etc/nginx/nginx.conf << EOF
user nginx;
worker_processes 4;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
  worker_connections 1024;
}

http {
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

  access_log  /var/log/nginx/access.log  main;

  sendfile            on;
  tcp_nopush          on;
  tcp_nodelay         on;
  keepalive_timeout   65;
  types_hash_max_size 4096;

  include             /etc/nginx/mime.types;
  default_type        application/octet-stream;

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;
  
  gzip on;
  gzip_disable 'msie6';
  
  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
EOF

mkdir -p /etc/nginx/sites-enabled/
> /etc/nginx/sites-enabled/clustering
cat >> /etc/nginx/sites-enabled/clustering << EOF
upstream clustering {
    server 127.0.0.1:8888;
}
# The following map statement is required
# if you plan to support channels. See https://www.nginx.com/blog/websocket-nginx/
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
server {
    client_max_body_size 0;
    listen 80 http;

    # server_name yourdomain.com;
    
    location = /favicon.ico {
      alias /var/www/favicon.ico;
    }
    
    location / {
        try_files $uri @proxy;
    }
    
    location @proxy {
        include proxy_params;
        proxy_redirect off;
        proxy_pass https://clustering;
        proxy_http_version 1.1;
        proxy_headers_hash_max_size 512;
        
        # The following two headers need to be set in order
        # to keep the websocket connection open. Otherwise you'll see
        # HTTP 400's being returned from websocket connections.
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Directories
mkdir -p /releases
mkdir -p /apps
mkdir -p /scripts
mkdir -p /var/log/clustering

# Systemd
> /etc/systemd/system/clustering.service
cat >> /etc/systemd/system/clustering.service << EOF
[Unit]
Description=Clustering Elixir application
After=network.target

[Service]
User=root
WorkingDirectory=/apps/clustering
ExecStart=/apps/clustering/bin/clustering start
ExecStop=/apps/clustering/bin/clustering stop
Restart=on-failure
RemainAfterExit=yes
RestartSec=5
SyslogIdentifier=clustering

[Install]
WantedBy=multi-user.target
EOF

systemctl enable clustering.service
systemctl start clustering.service

# IP Tables
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

# Secure linux
# semanage port -a -t http_port_t -p tcp 80
semanage port -a -t http_port_t -p tcp 8888

#!/bin/bash

finish () {
    wg-quick down wg0
    exit 0
}
trap finish SIGTERM SIGINT SIGQUIT

cat > /etc/nginx/nginx.conf << EOL
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

stream {
    server {
        listen ${PORT};
        proxy_pass ${SERVER}:10000;
    }
}
EOL

mkdir -p /etc/wireguard
touch /etc/wireguard/wg0.conf

cat > /etc/wireguard/wg0.conf << EOL
[Interface]
Address = 10.99.0.1/24
ListenPort = ${WG_PORT}
PrivateKey = ${WG_PRIVATE}

[Peer]
PublicKey = ${WG_PUBLIC}
AllowedIPs = 10.99.0.2/32
EOL

wg-quick up /etc/wireguard/wg0.conf

nginx -g "daemon off;"

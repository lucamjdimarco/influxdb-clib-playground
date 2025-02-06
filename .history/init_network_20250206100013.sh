#!/bin/bash

apt-get update && apt-get install -y --no-install-recommends \
    iproute2 net-tools iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


ETH0="eth0" # Rete di controllo
ETH1="eth1" # Rete dati


ip route del default dev $ETH0 2>/dev/null || echo "No default route on $ETH0 to remove."


ip rule add from 10.89.0.0/24 lookup main prio 1000
ip rule add to 10.89.0.0/24 lookup main prio 1001

ip -6 rule add from fd00:dead:beef::/48 lookup main prio 1000
ip -6 rule add to fd00:dead:beef::/48 lookup main prio 1001

ip rule add from 10.90.0.0/24 lookup main prio 1002
ip rule add to 10.90.0.0/24 lookup main prio 1003

ip -6 rule add from fd01:dead:beef::/48 lookup main prio 1002
ip -6 rule add to fd01:dead:beef::/48 lookup main prio 1003


if ! ip route | grep -q "default via 10.90.0.1 dev $ETH1"; then
    ip route add default via 10.90.0.1 dev $ETH1
fi

if ! ip -6 route | grep -q "default via fd01:dead:beef::1 dev $ETH1"; then
    ip -6 route add default via fd01:dead:beef::1 dev $ETH1
fi

exec "$@"
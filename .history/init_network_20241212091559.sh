#!/bin/bash

apt-get update && apt-get install -y --no-install-recommends \
    iproute2 net-tools iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


ETH0="eth0" # Rete di controllo
ETH1="eth1" # Rete dati

# Rimuovi il default da eth0 (rete di controllo)
ip route del default dev $ETH0 2>/dev/null || echo "No default route on $ETH0 to remove."

# Configura regole di routing per garantire che:
# - Pacchetti della rete di controllo viaggino solo su eth0
ip rule add from 10.89.0.0/24 lookup main prio 1000
ip rule add to 10.89.0.0/24 lookup main prio 1001

ip -6 rule add from fd00:dead:beef::/48 lookup main prio 1000
ip -6 rule add to fd00:dead:beef::/48 lookup main prio 1001

# - Pacchetti della rete dati viaggino solo su eth1
ip rule add from 10.90.0.0/24 lookup main prio 1002
ip rule add to 10.90.0.0/24 lookup main prio 1003

ip -6 rule add from fd01:dead:beef::/48 lookup main prio 1002
ip -6 rule add to fd01:dead:beef::/48 lookup main prio 1003

# Aggiungi default route per eth1
ip route add default via 10.90.0.1 dev $ETH1 || echo "Default route for data network already exists."
ip -6 route add default via fd01:dead:beef::1 dev $ETH1 || echo "Default IPv6 route for data network already exists."

exec "$@"
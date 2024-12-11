#!/bin/bash

apt-get update && apt-get install -y --no-install-recommends \
    iproute2 net-tools iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Interfacce di rete
ETH0="eth0" # Rete di controllo
ETH1="eth1" # Rete dati

# Reti
CONTROL_NET="10.89.0.0/24"
DATA_NET="10.90.0.0/24"
CONTROL_NET_IPV6="fd00:dead:beef::/48"
DATA_NET_IPV6="fd01:dead:beef::/48"

# Gateway della rete dati
DATA_GATEWAY="10.90.0.1"
DATA_GATEWAY_IPV6="fd01:dead:beef::1"


ip route del default dev $ETH0 2>/dev/null || echo "No default route on $ETH0 to remove."


ip rule add from $CONTROL_NET lookup main prio 1000
ip rule add to $CONTROL_NET lookup main prio 1001
ip -6 rule add from $CONTROL_NET_IPV6 lookup main prio 1000
ip -6 rule add to $CONTROL_NET_IPV6 lookup main prio 1001


ip rule add from $DATA_NET lookup main prio 2000
ip rule add to $DATA_NET lookup main prio 2001
ip -6 rule add from $DATA_NET_IPV6 lookup main prio 2000
ip -6 rule add to $DATA_NET_IPV6 lookup main prio 2001

ip rule add from $DATA_NET lookup prohibit prio 1500
ip rule add to $DATA_NET lookup prohibit prio 1501
ip -6 rule add from $DATA_NET_IPV6 lookup prohibit prio 1500
ip -6 rule add to $DATA_NET_IPV6 lookup prohibit prio 1501

ip rule add from $CONTROL_NET lookup prohibit prio 2500
ip rule add to $CONTROL_NET lookup prohibit prio 2501
ip -6 rule add from $CONTROL_NET_IPV6 lookup prohibit prio 2500
ip -6 rule add to $CONTROL_NET_IPV6 lookup prohibit prio 2501

ip route add default via $DATA_GATEWAY dev $ETH1 || echo "Default route for data network already exists."
ip -6 route add default via $DATA_GATEWAY_IPV6 dev $ETH1 || echo "Default IPv6 route for data network already exists."

exec "$@"
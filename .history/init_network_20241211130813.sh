#!/bin/bash

# Installa pacchetti necessari
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

# Rimuovi il default gateway da eth0 (rete di controllo) se esiste
ip route del default dev $ETH0 2>/dev/null || echo "No default route on $ETH0 to remove."

# Aggiungi regole per il traffico della rete di controllo
ip rule add from $CONTROL_NET lookup main prio 1000 2>/dev/null || echo "Rule from $CONTROL_NET already exists."
ip rule add to $CONTROL_NET lookup main prio 1001 2>/dev/null || echo "Rule to $CONTROL_NET already exists."
ip -6 rule add from $CONTROL_NET_IPV6 lookup main prio 1000 2>/dev/null || echo "Rule from $CONTROL_NET_IPV6 already exists."
ip -6 rule add to $CONTROL_NET_IPV6 lookup main prio 1001 2>/dev/null || echo "Rule to $CONTROL_NET_IPV6 already exists."

# Aggiungi regole per il traffico della rete dati
ip rule add from $DATA_NET lookup main prio 2000 2>/dev/null || echo "Rule from $DATA_NET already exists."
ip rule add to $DATA_NET lookup main prio 2001 2>/dev/null || echo "Rule to $DATA_NET already exists."
ip -6 rule add from $DATA_NET_IPV6 lookup main prio 2000 2>/dev/null || echo "Rule from $DATA_NET_IPV6 already exists."
ip -6 rule add to $DATA_NET_IPV6 lookup main prio 2001 2>/dev/null || echo "Rule to $DATA_NET_IPV6 already exists."

# Blocca il traffico incrociato usando "blackhole" per fermare il traffico
ip route add blackhole $CONTROL_NET metric 3000 2>/dev/null || echo "Blackhole route for $CONTROL_NET already exists."
ip route add blackhole $DATA_NET metric 3001 2>/dev/null || echo "Blackhole route for $DATA_NET already exists."
ip -6 route add blackhole $CONTROL_NET_IPV6 metric 3000 2>/dev/null || echo "Blackhole route for $CONTROL_NET_IPV6 already exists."
ip -6 route add blackhole $DATA_NET_IPV6 metric 3001 2>/dev/null || echo "Blackhole route for $DATA_NET_IPV6 already exists."

# Configura il default gateway per la rete dati (eth1)
ip route add default via $DATA_GATEWAY dev $ETH1 2>/dev/null || echo "Default route for data network already exists."
ip -6 route add default via $DATA_GATEWAY_IPV6 dev $ETH1 2>/dev/null || echo "Default IPv6 route for data network already exists."

exec "$@"
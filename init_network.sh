#!/bin/bash

apt-get update && apt-get install -y --no-install-recommends \
    iproute2 net-tools iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


ETH0="eth0" # Rete di controllo
ETH1="eth1" # Rete dati

ip route del default dev $ETH0 2>/dev/null || echo "No default route on $ETH0 to remove."

# ip route add default via 10.90.0.1 dev $ETH1 || echo "Default route for data network already exists."
# ip -6 route add default via fd01:dead:beef::1 dev $ETH1 || echo "Default IPv6 route for data network already exists."

# ip route add 10.89.0.0/24 dev $ETH0 || echo "Route for control network already exists."
# ip -6 route add fd00:dead:beef::/48 dev $ETH0 || echo "IPv6 route for control network already exists."

exec "$@"
#!/bin/bash

apt-get update && apt-get install -y --no-install-recommends \
    iptables iproute2 net-tools iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ETH0_INTERFACE="eth0"

iptables -F
iptables -A OUTPUT -o $ETH0_INTERFACE -d 0.0.0.0/0 -j DROP  # BLOCCA il traffico in uscita su eth0 verso Internet
iptables -A INPUT -i $ETH0_INTERFACE -s 10.89.0.0/24 -j ACCEPT  # PERMETTE traffico da rete di controllo
iptables -A INPUT -i $ETH0_INTERFACE -j DROP  # BLOCCA il traffico in ingresso non autorizzato su eth0

ip6tables -F
ip6tables -A OUTPUT -o $ETH0_INTERFACE -d ::/0 -j DROP  # BLOCCA traffico in uscita su eth0 verso Internet
ip6tables -A INPUT -i $ETH0_INTERFACE -s fd00:dead:beef::/48 -j ACCEPT  # PERMETTE traffico da rete di controllo
ip6tables -A INPUT -i $ETH0_INTERFACE -j DROP  # BLOCCA traffico in ingresso non autorizzato su eth0

ip route del default dev $ETH0_INTERFACE 2>/dev/null || echo "No default route on $ETH0_INTERFACE to remove."

exec "$@"
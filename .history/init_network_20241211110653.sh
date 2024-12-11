#!/bin/bash

apt-get update && apt-get install -y --no-install-recommends \
    iptables iproute2 net-tools iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ETH0_INTERFACE="eth0"
CONTROL_IPV4_SUBNET="10.89.0.0/24"
CONTROL_IPV6_SUBNET="fd00:dead:beef::/48"

iptables -F
ip6tables -F

iptables -A INPUT -i $ETH0_INTERFACE -s $CONTROL_IPV4_SUBNET -j ACCEPT  # Permette traffico in ingresso dalla rete di controllo
iptables -A OUTPUT -o $ETH0_INTERFACE -d $CONTROL_IPV4_SUBNET -j ACCEPT  # Permette traffico in uscita verso la rete di controllo
iptables -A OUTPUT -o $ETH0_INTERFACE -d 0.0.0.0/0 -j DROP  # Blocca traffico verso Internet
iptables -A INPUT -i $ETH0_INTERFACE -j DROP  # Blocca tutto il traffico non autorizzato

ip6tables -A INPUT -i $ETH0_INTERFACE -s $CONTROL_IPV6_SUBNET -j ACCEPT  # Permette traffico in ingresso dalla rete di controllo
ip6tables -A OUTPUT -o $ETH0_INTERFACE -d $CONTROL_IPV6_SUBNET -j ACCEPT  # Permette traffico in uscita verso la rete di controllo
ip6tables -A OUTPUT -o $ETH0_INTERFACE -d ::/0 -j DROP  # Blocca traffico verso Internet
ip6tables -A INPUT -i $ETH0_INTERFACE -j DROP  # Blocca tutto il traffico non autorizzato

ip route del default dev $ETH0_INTERFACE 2>/dev/null || echo "No default route on $ETH0_INTERFACE to remove."

exec "$@"
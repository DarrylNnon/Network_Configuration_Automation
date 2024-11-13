#!/bin/bash

# variables

INTERFACE="eth0"
IP_ADDR="192.168.1.100"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DNS_SERVER="8.8.8.8"

# 1. Configure IP address
echo "configuring IP address for  $INTERFACE"
sudo ip addr add $IP_ADDR/$NETMASK dev $INTERFACE
sudo ip link set $INTERFACE up

# 2. configure DNS
echo "setting up DNS server"
echo "nameserver $DNS_SERVER" | sudo tee/etc/resolv.conf > /dev/null

# 3. configure default gateway
echo "setting up default route"
sudo ip route add default via $GATWAY dev $INTERFACE

echo "Network configuration completed for $INTERFACE"

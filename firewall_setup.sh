#!/bin/bash

# variables
INTERNAL_INTERFACE="eth0"
EXTERNAL_INTERFACE="eth1"
FORWARD_PORT=8080
DEST_IP="192.168.1.100"
DEST_PORT=80


# 1. Set default policies
echo "setting default firewall policies"
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# 2. allow traffic on localhost and the internal network
echo "Allowing localhost and internal traffic"
sudo iptables -A INPUT -i lo -J ACCEPT
sudo iptables -A INPUT -i $INTERNAL_INTERFACE -J ACCEPT

# 3. Allow established connections
echo "setting up forwarding"
sudo iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport $FORWARD_PORT -j DNAT --to-destination
sudo iptables -A FORWARD -p tcp -d $DEST_IP --dport $DEST_PORT -j ACCEPT

# 5. save the configuration
echo "saving iptables rules"
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null

echo "Firewall and port forwarding  setup completed"

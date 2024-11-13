#!/bin/bash

# Variables
INTERFACE="eth0"
LOG_FILE="/tmp/network_status.log"
EMAIL="admin@example.com"

# Function to get IP address
get_ip() {
  ip -4 addr show $INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}

# Get current IP and check against previous IP
CURRENT_IP=$(get_ip)
LAST_IP=$(cat $LOG_FILE 2>/dev/null)

if [ "$CURRENT_IP" != "$LAST_IP" ]; then
  echo "Network change detected on $INTERFACE"
  echo "New IP: $CURRENT_IP" | mailx -s "Network Change Alert" $EMAIL

  # Update log file with current IP
  echo $CURRENT_IP > $LOG_FILE
else
  echo "No network changes detected."
fi

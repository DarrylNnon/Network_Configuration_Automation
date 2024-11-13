# Network_Configuration_Automation
To automate network configuration on Linux, we'll be developing scripts and using tools to simplify the setup of IP addresses, DNS, routing, firewall, and network monitoring with alerts. This type of automation ensure consistency, saves time, and reduces the risk of manual errors. 

I'll guide you step-by-step with explanations so that you can train your team afterward.


## Project Overview: Network Configuration Automation

We'll achieve the following in this project:
1. **Write scripts to configure IP addresses, DNS, and routing.**
2. **Automate firewall setup and port forwarding.**
3. **Monitor network traffic.**
4. **Implement alerts for network changes.**

This guide will use a mix of Bash scripting, networking commands, and Linux utilities for automation and monitoring.


### Prerequisites

1. **Root Access**: Ensure you have root access or equivalent privileges.
2. **Basic Scripting Knowledge**: Familiarity with Bash.
3. **Network Tools**: Install tools such as `net-tools`, `iptables`, `iftop`, and `mailx` (or an alternative mail client for alerts).


### 1. **Configuring IP Addresses, DNS, and Routing**

We'll write a script that:
- Configures a static IP address.
- Sets up DNS servers.
- Configures a default route.

#### **Step 1.1**: Script for Network Interface Configuration

**Script: `network_config.sh`**

```bash
#!/bin/bash

# Variables
INTERFACE="eth0"
IP_ADDR="192.168.1.100"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DNS_SERVER="8.8.8.8"

# 1. Configure IP address
echo "Configuring IP address for $INTERFACE"
sudo ip addr add $IP_ADDR/$NETMASK dev $INTERFACE
sudo ip link set $INTERFACE up

# 2. Configure DNS
echo "Setting up DNS server"
echo "nameserver $DNS_SERVER" | sudo tee /etc/resolv.conf > /dev/null

# 3. Configure default gateway
echo "Setting up default route"
sudo ip route add default via $GATEWAY dev $INTERFACE

echo "Network configuration completed for $INTERFACE"
```

- **Execution**: Make the script executable and run it.

  ```bash
  chmod +x network_config.sh
  sudo ./network_config.sh
  ```

- **Explanation**:
  - This script configures a static IP on `eth0`, sets up a DNS server, and configures a default route to reach external networks.
  - You can modify variables to adapt to your specific environment.


### 2. **Automate Firewall Setup and Port Forwarding**

We'll use `iptables` to set up basic firewall rules and port forwarding.

#### **Step 2.1**: Script for Firewall and Port Forwarding

**Script: `firewall_setup.sh`**

```bash
#!/bin/bash

# Variables
INTERNAL_INTERFACE="eth0"
EXTERNAL_INTERFACE="eth1"
FORWARD_PORT=8080
DEST_IP="192.168.1.100"
DEST_PORT=80

# 1. Set default policies
echo "Setting default firewall policies"
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# 2. Allow traffic on localhost and the internal network
echo "Allowing localhost and internal traffic"
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -i $INTERNAL_INTERFACE -j ACCEPT

# 3. Allow established connections
echo "Allowing established connections"
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 4. Forward traffic from external to internal IP
echo "Setting up port forwarding"
sudo iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport $FORWARD_PORT -j DNAT --to-destination $DEST_IP:$DEST_PORT
sudo iptables -A FORWARD -p tcp -d $DEST_IP --dport $DEST_PORT -j ACCEPT

# 5. Save the configuration
echo "Saving iptables rules"
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null

echo "Firewall and port forwarding setup completed"
```

- **Execution**:

  ```bash
  chmod +x firewall_setup.sh
  sudo ./firewall_setup.sh
  ```

- **Explanation**:
  - This script sets basic firewall policies, allows internal traffic, and forwards external traffic from port 8080 to an internal server’s port 80.
  - Modify the interface names, ports, and destination IP based on your environment.
  - Saving rules ensures they persist after reboot.


### 3. **Monitor Network Traffic**

We can use tools like `iftop` or `ntop` for real-time traffic monitoring. Here, we’ll set up `iftop` in monitoring mode.

#### **Step 3.1**: Script for Network Traffic Monitoring

**Monitoring with `iftop`**:
  - Install `iftop` (if not installed): `sudo apt install iftop -y`
  - Run `iftop` for monitoring traffic on a specific interface.

```bash
sudo iftop -i eth0
```


### 4. **Implement Alerts for Network Changes**

Network monitoring and alerting can be done using tools like `netstat` and by sending alerts with `mailx`.

#### **Step 4.1**: Script for Network Alerting

**Script: `network_alert.sh`**

This script checks for changes in the network interface IP address and sends an email alert if any are detected.

```bash
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
```

- **Execution**:

  ```bash
  chmod +x network_alert.sh
  ./network_alert.sh
  ```

- **Explanation**:
  - This script checks the IP of `eth0`, compares it with the last recorded IP, and if it’s different, sends an alert.
  - **Cron Job**: You can set up a cron job to run this script periodically.

---

### Summary

1. **IP Configuration and DNS**: The `network_config.sh` script sets IP, DNS, and routing.
2. **Firewall and Port Forwarding**: `firewall_setup.sh` manages firewall rules and forwards specific traffic.
3. **Network Monitoring**: Use `iftop` for real-time traffic monitoring.
4. **Alerting**: `network_alert.sh` alerts on network changes.


### Additional Notes

- **Testing**: Test each script separately in a development environment before deploying to production.
- **Logging**: Consider adding logging for each step to track activity.
- **Security**: Ensure that your firewall rules are tested for potential security gaps.

This setup will help you maintain a secure and efficient network configuration that can be automated and monitored, and now you’ll be ready to train your team on each step.

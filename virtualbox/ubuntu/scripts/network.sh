#!/bin/bash

echo "Configuring Network Interface..."

# Get network interface name
NETWORK_INTERFACE=$(ip r | grep default | cut -f5 -d' ')
NETWORK_MANAGER="networkd"
END_CONFIG=/etc/netplan/01-network-card.yaml

echo "$NETWORK_INTERFACE"

createNetworkInterfaceYAML() {
  local YAML="network:\n"
  YAML+="    version: 2\n"
  YAML+="    renderer: $NETWORK_MANAGER\n"
  YAML+="    ethernets:\n"
  YAML+="        $DEVICE_NAME:\n"
  YAML+="            dhcp4: yes\n"
  printf "%s" "$YAML"
}

backupConfigs() {
  [ -f $END_CONFIG ] && sudo mv $END_CONFIG "$END_CONFIG.backup"
}

setYAML() {
  echo -e "$(createStaticYAML)" > $END_CONFIG
}

restartNetwork() {
  netplan apply
  ip link set "$NETWORK_INTERFACE" down
  ip lnke set "$NETWORK_INTERFACE" up
}

createDHCPScript() {
  local SCRIPT="#!/bin/bash\n"
  SCRIPT+="dhclient\n"
  SCRIPT+="exit 0"
  printf "%s" "$YAML"
}

setDHCPConfig() {
  echo -e "$(createDHCPScript)" > /etc/rc.local
  chmod 755 /etc/rc.local
  systemctl enable rc-local
  systemctl restart rc-local
  systemctl status rc-local
}

backupConfigs
createNetworkInterfaceYAML
setYAML
restartNetwork
createDHCPScript
setDHCPConfig

echo "Done"

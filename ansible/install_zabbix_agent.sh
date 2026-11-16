#!/bin/bash
set -euo pipefail

ZABBIX_SERVER="10.10.10.100"
AGENT_CONFIG="/etc/zabbix/zabbix_agent2.conf"

export DEBIAN_FRONTEND=noninteractive

echo "Installing Zabbix Agent 2 on $(hostname)"

apt-get update
apt-get install -y zabbix-agent2

# Remove existing active/passive server and hostname directives to avoid duplicates.
sed -i \
  -e '/^[[:space:]]*Server=/d' \
  -e '/^[[:space:]]*ServerActive=/d' \
  -e '/^[[:space:]]*Hostname=/d' \
  "$AGENT_CONFIG"

cat >> "$AGENT_CONFIG" <<EOF

# Managed by Ansible deployment
Server=${ZABBIX_SERVER}
ServerActive=${ZABBIX_SERVER}
Hostname=$(hostname)
EOF

systemctl enable zabbix-agent2
systemctl restart zabbix-agent2

systemctl is-active --quiet zabbix-agent2
echo "Zabbix Agent 2 is active on $(hostname)"

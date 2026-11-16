# Ansible deployment

These instructions describe how the Zabbix Agent 2 deployment was automated from `omZabbix01`.

## 1. Prepare SSH access

On the Ansible control node, create an SSH key if one does not already exist:

```bash
ssh-keygen -t ed25519 -C "cloudvc@omZabbix01"
```

Copy the public key to each target host:

```bash
ssh-copy-id cloudvc@10.10.10.70
ssh-copy-id cloudvc@10.10.10.71
ssh-copy-id cloudvc@10.10.10.72
ssh-copy-id cloudvc@10.10.10.73
ssh-copy-id cloudvc@10.10.10.74
```

Do not copy or upload the private key to this repository.

## 2. Install Ansible

```bash
sudo apt update
sudo apt install -y ansible
```

## 3. Prepare inventory

Copy the example inventory and edit it for your environment:

```bash
cp ansible/inventory.ini.example ansible/inventory
```

The lab used `cloudvc` as the SSH user.

## 4. Check SSH connectivity

```bash
ansible -i ansible/inventory zabbix_clients \
  -m raw -a "hostname && python3 --version"
```

## 5. Deploy the agent

Make the script executable:

```bash
chmod +x ansible/install_zabbix_agent.sh
```

Run it against the five hosts:

```bash
ansible -i ansible/inventory zabbix_clients \
  -b -K \
  -e ansible_become_exe=/usr/bin/sudo.ws \
  -m script -a "$HOME/Zabbix-Monitoring/ansible/install_zabbix_agent.sh"
```

### Lab-specific Ansible compatibility note

The lab control node used Ansible 2.10.8 while the target VMs used Python 3.13.7. The standard `ping` module failed because of an Ansible module-utils compatibility issue. The `raw` and `script` modules were used to bootstrap the agents.

The target VMs used `sudo-rs`; Ansible privilege escalation was successfully run with `/usr/bin/sudo.ws` as `ansible_become_exe`. This path is environment-specific. Check the available sudo executable on your own systems before reusing it.

## 6. Verify agent service and listener

```bash
ansible -i ansible/inventory zabbix_clients \
  -b -K \
  -e ansible_become_exe=/usr/bin/sudo.ws \
  -m raw -a "systemctl is-active zabbix-agent2; ss -lntp | grep ':10050'"
```

## 7. Configure UFW on target hosts

Allow the Zabbix server only:

```bash
sudo ufw allow from 10.10.10.100 to any port 10050 proto tcp
```

Apply only where this rule is not already present. Do not flush or replace existing firewall rules.

## 8. Test from the Zabbix server

```bash
sudo apt install -y zabbix-get

for ip in 10.10.10.70 10.10.10.71 10.10.10.72 10.10.10.73 10.10.10.74; do
  echo "Testing $ip"
  nc -zvw3 "$ip" 10050
  zabbix_get -s "$ip" -k agent.ping
done
```

Expected `agent.ping` response: `1`.

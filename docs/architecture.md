# Architecture

## Logical design

- `omZabbix01` is the central Zabbix server and Ansible control node.
- Ansible connects to the monitored VMs over SSH (TCP 22) to install and configure Zabbix Agent 2.
- Zabbix Server polls each agent over TCP 10050 for passive checks.
- Each target's UFW rule should allow TCP 10050 only from `10.10.10.100`.
- Existing Nagios/NRPE monitoring remains separate and uses TCP 5666.

## Host inventory

| Role | Hostname | IP | Application |
|---|---|---:|---|
| Monitoring | `omZabbix01` | `10.10.10.100` | Zabbix Server |
| Database | `omdb01` | `10.10.10.70` | MariaDB |
| Cache | `ommc01` | `10.10.10.71` | Memcached |
| Messaging | `omrmq01` | `10.10.10.72` | RabbitMQ |
| Application | `omapp01` | `10.10.10.73` | Tomcat |
| Web | `omweb01` | `10.10.10.74` | Nginx |

## Network flows

| Source | Destination | Port | Purpose |
|---|---|---:|---|
| `omZabbix01` | Monitored VMs | TCP 22 | Ansible over SSH |
| `omZabbix01` | Monitored VMs | TCP 10050 | Zabbix passive agent checks |
| Agents (if active checks enabled) | `omZabbix01` | TCP 10051 | Active checks |

The actual firewall policy should be validated against the deployed Zabbix check mode and network security controls.

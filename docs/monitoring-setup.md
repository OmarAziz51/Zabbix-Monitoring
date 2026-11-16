# Zabbix server and frontend setup

This document summarizes the Zabbix server-side setup completed in the lab.

## Zabbix server

| Setting | Value |
|---|---|
| Hostname | `omZabbix01` |
| IP | `10.10.10.100` |
| OS | Ubuntu Server 22.04 LTS |
| Zabbix version | 7.0.32 |
| Database | MySQL 8.0 |
| Frontend URL | `http://10.10.10.100/zabbix` |

The Zabbix server, frontend, Apache configuration, SQL scripts, and Zabbix Agent 2 packages were installed. A MySQL database named `zabbix` was created and initialized using the packaged Zabbix SQL schema.

**Do not publish** `/etc/zabbix/zabbix_server.conf`, database credentials, or any exported configuration containing secrets.

## Import the Linux template

1. Download the official Linux template YAML from the Zabbix `release/7.0` branch.
2. In the frontend, open **Data collection → Templates → Import**.
3. Select the downloaded YAML file and import it.
4. Confirm that `Linux by Zabbix agent` is available.

Official template source:

- https://raw.githubusercontent.com/zabbix/zabbix/release/7.0/templates/os/linux/template_os_linux.yaml

## Add monitored hosts

For each host, open **Data collection → Hosts → Create host**.

Use these settings:

- Host name: exact VM hostname
- Host group: `Linux servers` (create it if it does not exist)
- Template: `Linux by Zabbix agent`
- Interface: Agent
- Connect to: IP
- Port: `10050`

| Host | Agent interface IP |
|---|---|
| `omdb01` | `10.10.10.70` |
| `ommc01` | `10.10.10.71` |
| `omrmq01` | `10.10.10.72` |
| `omapp01` | `10.10.10.73` |
| `omweb01` | `10.10.10.74` |

The passive agent availability indicator (ZBX) should become green after connectivity and configuration are correct.

## Initial checks

Use **Monitoring → Hosts** and **Monitoring → Latest data** to confirm that metrics are arriving. Depending on the template and host OS, common metrics include CPU, memory, filesystem, network interfaces, and uptime.

## Next improvements

- Add application-level checks for MariaDB, Memcached, RabbitMQ, Tomcat, and Nginx.
- Configure triggers and notification actions.
- Create dashboards for service health and capacity.
- Configure backups for the Zabbix database and server configuration.
- Review retention and housekeeping settings.

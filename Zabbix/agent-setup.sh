#!/bin/bash

# Aktualizace systému
dnf update -y

# Přidání Zabbix repozitáře a instalace Zabbix agenta
rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-7.0-4.el9.noarch.rpm
dnf clean all
dnf install -y zabbix-agent

# Konfigurace Zabbix agenta
sed -i 's/^Server=127.0.0.1/Server=zabbix-server/' /etc/zabbix/zabbix_agent2.conf
sed -i 's/^ServerActive=127.0.0.1/ServerActive=zabbix-server/' /etc/zabbix/zabbix_agent2.conf
sed -i 's/^Hostname=Zabbix server/Hostname=zabbix-agent/' /etc/zabbix/zabbix_agent2.conf

# Spuštění Zabbix agenta
systemctl enable --now zabbix-agent

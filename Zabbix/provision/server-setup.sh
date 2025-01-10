#!/bin/bash

# Aktualizace systému
dnf update -y

# Instalace EPEL a dalších repozitářů
dnf install -y epel-release

# Instalace MariaDB
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
dnf install -y mariadb-server mariadb

# Spuštění MariaDB
systemctl enable --now mariadb

# Nastavení databáze Zabbix
mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix_pass';"
mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Přidání Zabbix repozitáře a instalace balíčků
rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-7.0-4.el9.noarch.rpm
dnf clean all
dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent

# Import databázového schématu
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -u zabbix -pzabbix_pass zabbix

# Konfigurace Zabbix serveru
sed -i 's/^# DBPassword=/DBPassword=zabbix_pass/' /etc/zabbix/zabbix_server.conf

# Spuštění Zabbix serveru a Apache
systemctl enable --now zabbix-server
systemctl enable --now httpd

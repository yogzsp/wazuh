#!/bin/bash

# Periksa apakah skrip dijalankan dengan hak akses root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Periksa apakah jumlah argumen yang diberikan benar
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <SERVER_IP> <AGENT_KEY>"
    exit 1
fi

# Variabel input dari argumen
SERVER_IP=$1
AGENT_KEY=$2

# Unduh Wazuh agent .rpm (amd64)
AGENT_FILE="wazuh-agent-4.7.4-1.x86_64.rpm"
curl -o ./$AGENT_FILE https://packages.wazuh.com/4.x/yum/$AGENT_FILE

# Instal Wazuh agent .rpm (amd64)
sudo rpm -ivh ./$AGENT_FILE

# Buat backup file konfigurasi
sudo cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.bak

# Modifikasi nilai MANAGER_IP dalam tag <address> di dalam tag <client>
sudo sed -i "s|<address>.*</address>|<address>$SERVER_IP</address>|" /var/ossec/etc/ossec.conf

# Tambahkan agent menggunakan manage_agents dan jawab "y" secara otomatis
echo "y" | sudo /var/ossec/bin/manage_agents -i $AGENT_KEY

# Restart layanan Wazuh agent
sudo systemctl restart wazuh-agent
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

# Hapus file unduhan
rm -f ./$AGENT_FILE

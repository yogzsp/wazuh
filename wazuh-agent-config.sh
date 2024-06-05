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

# Unduh Wazuh agent
AGENT_FILE="wazuh-agent_4.7.4-1_amd64.deb"
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/$AGENT_FILE

# Instal Wazuh agent
sudo dpkg -i ./$AGENT_FILE

# Buat backup file konfigurasi
sudo cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.bak

# Modifikasi nilai MANAGER_IP dalam tag <address> di dalam tag <client>
sudo sed -i "s|<address>.*</address>|<address>$SERVER_IP</address>|" /var/ossec/etc/ossec.conf

# Set agent name di file local_internal_options.conf (opsional)
# echo "agent.name=$AGENT_NAME" | sudo tee -a /var/ossec/etc/local_internal_options.conf

# Restart layanan Wazuh agent

# Hapus file unduhan

# Tambahkan agent menggunakan manage_agents dan jawab "y" secara otomatis
echo "y" | sudo /var/ossec/bin/manage_agents -i $AGENT_KEY


sudo systemctl restart wazuh-agent
# Restart layanan Wazuh agent
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
rm -f ./$AGENT_FILE
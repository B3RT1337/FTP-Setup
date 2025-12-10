#!/bin/bash

echo "=========================================="
echo "           FTP Auto Setup Script"
echo "=========================================="

# FTP username & password
read -p "Enter FTP username: " FTPUSER
read -sp "Enter FTP password: " FTPPASS
echo ""

# Detect public IP
SERVER_IP=$(curl -s https://ipinfo.io/ip)
echo "[+] Detected VPS IP: $SERVER_IP"

echo "[+] Updating & installing vsftpd..."
apt update -y
apt install vsftpd -y

echo "[+] Backing up original configuration..."
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak 2>/dev/null

echo "[+] Applying FTP configuration..."
cat <<EOF > /etc/vsftpd.conf
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pam_service_name=vsftpd

# Passive FTP settings
pasv_enable=YES
pasv_min_port=30000
pasv_max_port=31000
EOF

echo "[+] Restarting vsftpd..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "[+] Creating FTP user..."
adduser --disabled-password --gecos "" "$FTPUSER"
echo "$FTPUSER:$FTPPASS" | chpasswd

echo "[+] Creating FTP directory..."
mkdir -p /home/$FTPUSER/ftp
chown $FTPUSER:$FTPUSER /home/$FTPUSER/ftp

echo "[+] Opening firewall ports..."
ufw allow 20/tcp
ufw allow 21/tcp
ufw allow 30000:31000/tcp

echo ""
echo "=========================================="
echo "          FTP Setup Completed"
echo "=========================================="
echo "IP: $SERVER_IP"
echo "Username: $FTPUSER"
echo "Password: $FTPPASS"
echo "Port: 21"
echo "Mode: Passive"
echo "Directory: /home/$FTPUSER/ftp"
echo "=========================================="
echo "Setup complete!"

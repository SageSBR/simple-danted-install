#!/bin/sh

# Danted install script

password=$1

if [ "$#" -ne 1 ]; then
	echo "Incorrect amount of parameters!\nUsage: ./danteinstall.sh <password>"
	exit 1
fi

sudo apt update
sudo apt install dante-server -y
wget http://archive.ubuntu.com/ubuntu/pool/universe/d/dante/dante-server_1.4.2+dfsg-2build1_amd64.deb
sudo dpkg -i dante-server_*.deb
sudo useradd --shell /usr/sbin/nologin proxyuser
echo "proxyuser:$password" | chpasswd

echo "Copy config to /etc/danted.conf ..."
echo "logoutput: syslog
user.privileged: root
user.unprivileged: nobody
internal: 0.0.0.0 port = 8080
external: eth0
socksmethod: username
clientmethod: none
user.libwrap: nobody
client pass {
        from: 0/0 to: 0/0
        log: connect disconnect error
}
socks pass {
        from: 0/0 to: 0/0
        log: connect disconnect error
}" | sudo tee /etc/danted.conf

sudo systemctl restart danted
sudo systemctl enable danted
sudo systemctl status danted

echo "Install complete.\nYou can use proxyuser and the supplied password to log into the proxy!"

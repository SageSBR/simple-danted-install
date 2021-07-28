#!/bin/sh

# Danted install script

password=$1

if [ "$#" -ne 1 ]; then
	echo "Incorrect amount of parameters!\nUsage: ./danteinstall.sh <password>"
	exit 1
fi

apt update
wget http://archive.ubuntu.com/ubuntu/pool/universe/d/dante/dante-server_1.4.2+dfsg-7build3.1_amd64.deb
dpkg -i dante-server_*.deb
useradd --shell /usr/sbin/nologin proxyuser
echo "proxyuser:$password" | chpasswd

echo "Copy config to /etc/danted.conf ..."
echo "logoutput: syslog
user.privileged: root
user.unprivileged: nobody
internal: 0.0.0.0 port = 1080
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
}" | tee /etc/danted.conf

systemctl restart danted
systemctl enable danted
systemctl status danted

echo "Install complete.\nYou can use proxyuser and the supplied password to log into the proxy!"

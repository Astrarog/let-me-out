
# installing tun2socks
wget -O /tmp/go1.21.6.linux-amd64.tar.gz https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
sudo -i
rm -rf /usr/local/go && tar -C /usr/local -xzf /tmp/go1.21.6.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
GOBIN=/usr/local/bin/ go install github.com/xjasonlyu/tun2socks/v2@latest
exit

# installing wireguard
# https://github.com/hwdsl2/wireguard-install
# NOTE to self: Most of the connection problems are with the firewalls...
wget -O wireguard.sh https://get.vpnsetup.net/wg
chmod +x wireguard.sh


# activating the wireguard
sudo ./wireguard.sh


# creating tun0 adapter for tun2socks and running it as a daemon

sudo cp services/tun2socks /etc/systemd/system/tun2socks
sudo echo '20 lip' >> /etc/iproute2/rt_tables

systemctl enable --now tun2socks


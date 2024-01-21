
# installing shadowsocks-rust
sudo apt update && sudo apt upgrade -y 
sudo apt install -y build-essential

curl https://sh.rustup.rs -sSf | sh
source .bashrc

# Don't install as root. Just as a regular user
cargo install shadowsocks-rust

sudo cp .cargo/bin/ssserver /usr/local/bin/

sudo mkdir -m 755 /etc/shadowsocks
sudo cp ss-server.json /etc/shadowsocks/sssconfig.json

sudo cp services/ssserver.service /etc/systemd/system/ssserver.service
sudo systemctl enable --now ssserver.service


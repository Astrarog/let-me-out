# Let me out scheme

```
┌──────────────────────────────────────────────┐
│                 Device                       │
│      (phone / laptop with WireGuard)         │
└──────────────────────────────────────────────┘
                   │
                   │   encrypted UDP (WireGuard)
                   ▼
┌──────────────────────────────────────────────┐
│              FIRST-HOP  VPS                  │
│   • wg0 (WireGuard server)                   │
│   • tun2socks  ─┬─►  tcp+udp over Shadowsocks│
└─────────────────┬────────────────────────────┘
                  │
                  │  chacha20-ietf-poly1305  (SS)
                  ▼
┌──────────────────────────────────────────────┐
│                EXIT-HOP  VPS                 │
│   • ssserver  (Shadowsocks-rust)             │
└─────────────────┬────────────────────────────┘
                  │
                  │  plain Internet traffic
                  ▼
            ──────┴──────►   🌍  Internet

```

---

## 1. Quick start

### Deployment

```bash
# 0) Install Ansible (Ubuntu example)
sudo apt update && sudo apt install -y ansible git

# 1) Copy and edit .env file
cp .env.example .env          # edit IPs / keys / password

# 2) Export environment variables
set -a; . ./.env; set +a

# 3) Smoke test: SSH reachability
ansible -i inventory.yml ss_chain -m ping

# 4) Configure exit-hop (Shadowsocks server)
ansible-playbook -i inventory.yml playbooks/exithop.yml

# 5) Configure first-hop (WireGuard + Shadowsocks client)
ansible-playbook -i inventory.yml playbooks/firsthop.yml
```

> **Re-run safe:** playbooks are idempotent — nothing restarts unless configs change.

### WireGuard configs

Connect to the first hop host (with ip `$FH_IP`) via ssh and configure client via `/root/wireguard.sh` script. It is self explanatory.

```bash
ssh -i $FH_KEY $FH_USER@$FH_IP
sudo /root/wireguard.sh
# follow instructions
```

---

## 3. Variables cheat-sheet

| Variable                     | Meaning                               |
| ---------------------------- | ------------------------------------- |
| `FH_IP`, `FH_KEY`, `FH_USER` | First-hop public IP, SSH key and user |
| `EH_IP`, `EH_KEY`, `EH_USER` | Exit-hop public IP, SSH key and user  |
| `SS_PORT`                    | Port shadowsocks listens on           |
| `SS_PASSWORD`                | Shared shadowsocks secret             |


---

## 4. Workflow in detail

1. **shadowsocks\_server**
   * Updates APT, installs `build-essential`
   * Creates user `ssbuild`, installs Rust, compiles **shadowsocks-rust**
   * Places `ssserver` in `/usr/local/bin`, templated config in `/etc/shadowsocks`
   * Installs and (re)starts `ssserver.service`

2. **shadowsocks\_client**
   * Installs Go 1.21.6, builds **tun2socks** (`go install …`)
   * Renders `/etc/default/tun2socks` (password/port/IP)
   * Adds `tun0` via systemd unit, restarts only on change
   * Ensures custom routing table `20 lip` exists

3. **wireguard\_install**
   * Downloads *hwdsl2/wireguard-install* script
   * Runs it non-interactive \(`AUTO_INSTALL=y`\) for keys and `wg0.conf`config generation 


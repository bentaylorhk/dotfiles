#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Sets up polyphonic-1 as an ARK: Survival Evolved server with LAN-only SSH.
# Run as root after installing steamcmd from the AUR:
#   ~/scripts/aur.sh steamcmd
#   sudo ~/scripts/ark/setup.sh

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root (sudo)." >&2; exit 1; }
[[ "$(cat /etc/hostname)" = "polyphonic-1" ]] || { echo "Wrong host." >&2; exit 1; }

USER_NAME="${SUDO_USER:-ben}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
REPO_DIR="$USER_HOME"
LAN="192.168.1.0/24"
ARK_DIR=/srv/ark-se

command -v steamcmd >/dev/null || { echo "steamcmd missing: run ~/scripts/aur.sh steamcmd" >&2; exit 1; }

# Refusing to disable SSH passwords without a key in place
if [[ ! -s "$USER_HOME/.ssh/authorized_keys" ]]; then
  echo "Add your client's public key to $USER_HOME/.ssh/authorized_keys first." >&2
  exit 1
fi
chmod 700 "$USER_HOME/.ssh"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
chown -R "$USER_NAME": "$USER_HOME/.ssh"

pacman -S --needed --noconfirm ufw

# ARK service account and install
getent group ark >/dev/null || groupadd --system ark
getent passwd ark >/dev/null ||
  useradd --system --gid ark --home-dir "$ARK_DIR" --shell /usr/bin/nologin ark
install -d -o ark -g ark -m 0755 "$ARK_DIR"
sudo -u ark -H steamcmd +force_install_dir "$ARK_DIR" +login anonymous +app_update 376030 validate +quit

# ARK needs a larger memory map count
echo "vm.max_map_count=262144" >/etc/sysctl.d/99-ark.conf
sysctl --system >/dev/null

# SSH: keys only, no root
cat >/etc/ssh/sshd_config.d/10-hardening.conf <<EOF
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
EOF
sshd -t
systemctl enable --now sshd.service
systemctl reload sshd.service

# Firewall: SSH from LAN only, ARK ports open
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from "$LAN" to any port 22 proto tcp
ufw allow 7777/udp
ufw allow 7778/udp
ufw allow 27015/udp
ufw --force enable
systemctl enable --now ufw.service

# ARK service
install -D -m 0644 "$REPO_DIR/systemd/ark-server.service" /etc/systemd/system/ark-server.service
systemctl daemon-reload
systemctl enable --now ark-server.service

"$REPO_DIR/scripts/ark/install-backup.sh"

systemctl --no-pager status sshd ufw ark-server | grep -E '^(●|\s+Active)'

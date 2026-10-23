#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Installs the nightly ARK save backup (polyphonic-1 only). Run with sudo:
#   sudo ~/scripts/ark/install-backup.sh

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root (sudo)." >&2; exit 1; }
[[ "$(cat /etc/hostname)" = "polyphonic-1" ]] || { echo "Wrong host." >&2; exit 1; }

REPO_DIR="$(getent passwd "${SUDO_USER:-ben}" | cut -d: -f6)"

install -d -o ark -g ark -m 0750 /srv/ark-backups
install -m 0755 "$REPO_DIR/scripts/ark/backup.sh" /usr/local/bin/ark-backup.sh
install -m 0644 "$REPO_DIR/systemd/ark-backup.service" /etc/systemd/system/ark-backup.service
install -m 0644 "$REPO_DIR/systemd/ark-backup.timer" /etc/systemd/system/ark-backup.timer

systemctl daemon-reload
systemctl enable --now ark-backup.timer
systemctl start ark-backup.service
systemctl list-timers ark-backup.timer --no-pager

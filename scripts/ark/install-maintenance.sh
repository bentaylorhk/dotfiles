#!/usr/bin/env bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Installs the ARK server unit and its maintenance tools: safe shutdown over
# RCON, weekly restart with warnings, health check and backup/log cleanup.
# Run with: sudo ~/scripts/ark/install-maintenance.sh

set -euo pipefail

[[ "$EUID" -eq 0 ]] || {
  echo "Run with sudo: sudo ~/scripts/ark/install-maintenance.sh" >&2
  exit 1
}
[[ "$(cat /etc/hostname)" == "polyphonic-1" ]] || {
  echo "This script only runs on polyphonic-1." >&2
  exit 1
}

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

install -Dm0755 "$DOTFILES/scripts/ark/rcon.py" /usr/local/bin/ark-rcon
install -Dm0755 "$DOTFILES/scripts/ark/safe-stop.sh" /usr/local/bin/ark-safe-stop
install -Dm0755 "$DOTFILES/scripts/ark/weekly-restart.sh" /usr/local/bin/ark-weekly-restart
install -Dm0755 "$DOTFILES/scripts/ark/health.py" /usr/local/bin/ark-health
install -Dm0755 "$DOTFILES/scripts/ark/backup.sh" /usr/local/bin/ark-backup.sh

for unit in ark-server.service ark-backup.service ark-backup.timer \
  ark-restart.service ark-restart.timer ark-health.service ark-health.timer; do
  install -Dm0644 "$DOTFILES/systemd/$unit" "/etc/systemd/system/$unit"
done

systemctl daemon-reload
systemctl enable ark-server.service ark-backup.timer
systemctl enable --now ark-restart.timer ark-health.timer
systemctl list-timers 'ark-*' --no-pager
echo "Installed. Deploy the config next so RCON is enabled: ~/scripts/ark/deploy-config.sh"

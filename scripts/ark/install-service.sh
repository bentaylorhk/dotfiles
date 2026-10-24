#!/usr/bin/env bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Installs the tracked ARK service unit and enables SteamCMD updates on start.

set -euo pipefail

[[ "$EUID" -eq 0 ]] || {
  echo "Run with sudo: sudo ~/scripts/ark/install-service.sh" >&2
  exit 1
}
[[ "$(cat /etc/hostname)" == "polyphonic-1" ]] || {
  echo "This script only runs on polyphonic-1." >&2
  exit 1
}

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
install -Dm0644 "$DOTFILES/systemd/ark-server.service" \
  /etc/systemd/system/ark-server.service
systemctl daemon-reload
systemctl enable ark-server.service
echo "Installed and enabled ark-server.service."

#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025-2026

# Installs the polyOS startup animation and tty1 login banner.

set -euo pipefail

SYSTEM_DIR=/usr/local/share
SYSTEM_ASCII_ART_DIR="$SYSTEM_DIR/ascii-art"

sudo install -D -m 0644 "$HOME/ascii-art/polyOS/caligraphy.txt" \
  "$SYSTEM_ASCII_ART_DIR/boot.txt"
sudo install -D -m 0644 "$HOME/ascii-art/gecko.txt" \
  "$SYSTEM_ASCII_ART_DIR/login.txt"
sudo install -D -m 0644 "$HOME/scripts/startup/formatted-issue" \
  "$SYSTEM_DIR/formatted-issue"
sudo install -D -m 0755 "$HOME/scripts/startup/startup.sh" \
  /usr/local/bin/startup.sh
sudo install -D -m 0755 "$HOME/scripts/startup/boot-animation" \
  /usr/local/bin/boot-animation
sudo install -D -m 0755 "$HOME/scripts/justify.sh" \
  /usr/local/bin/justify.sh
sudo install -D -m 0644 "$HOME/systemd/startup.service" \
  /etc/systemd/system/startup.service
sudo install -D -m 0644 "$HOME/systemd/getty@tty1.service.d/override.conf" \
  /etc/systemd/system/getty@tty1.service.d/override.conf

"$HOME/fonts/scientifica/psf/push_font.sh"

sudo systemctl daemon-reload
sudo systemctl enable startup.service getty@tty1.service
echo "Installed. Reboot polyOS to re-run the startup banner before tty1 login."

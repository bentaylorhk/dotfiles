#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025-2026

set -euo pipefail

FONT=scientifica.psf
FONT_SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$FONT"
FONT_DIR=/usr/share/kbd/consolefonts

sudo install -D -m 0644 "$FONT_SOURCE" "$FONT_DIR/$FONT"
if sudo grep -q '^FONT=' /etc/vconsole.conf; then
  sudo sed -i "s/^FONT=.*/FONT=$FONT/" /etc/vconsole.conf
else
  printf 'FONT=%s\n' "$FONT" | sudo tee -a /etc/vconsole.conf >/dev/null
fi
sudo systemctl restart systemd-vconsole-setup.service

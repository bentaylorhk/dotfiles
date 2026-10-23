#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Copies the live ARK config into the ark-server config repo with passwords
# redacted. Run with sudo, since the live files are only readable by 'ark'.
#   sudo ~/scripts/ark/sync-config.sh

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root (sudo)." >&2; exit 1; }

OWNER="${SUDO_USER:-ben}"
SRC=/srv/ark-se/ShooterGame/Saved/Config/LinuxServer
DEST="$(getent passwd "$OWNER" | cut -d: -f6)/repos/ark-server/config"

install -d -o "$OWNER" -g "$OWNER" "$DEST"
for name in GameUserSettings.ini Game.ini Engine.ini; do
  [[ -f "$SRC/$name" ]] || continue
  sed -E 's/^((Server|ServerAdmin|Spectator|RCON)Password)=.*/\1=CHANGE_ME/I' \
    "$SRC/$name" | tr -d '\r' >"$DEST/$name"
  chown "$OWNER:$OWNER" "$DEST/$name"
done

echo "Synced to $DEST (passwords redacted). Review, then commit in ~/repos/ark-server."

#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Copies the live ARK config into the ark-server config repo with passwords
# redacted. Needs membership of the 'ark' group (the live files are group
# readable), not root.
#   ~/scripts/ark/sync-config.sh

set -euo pipefail

SRC=/srv/ark-se/ShooterGame/Saved/Config/LinuxServer
DEST="$HOME/repos/ark-server/config"

mkdir -p "$DEST"
for name in GameUserSettings.ini Game.ini Engine.ini; do
  [[ -f "$SRC/$name" ]] || continue
  sed -E 's/^((Server|ServerAdmin|Spectator|RCON)Password)=.*/\1=CHANGE_ME/I' \
    "$SRC/$name" | tr -d '\r' >"$DEST/$name"
done

echo "Synced to $DEST (passwords redacted). Review, then commit in ~/repos/ark-server."

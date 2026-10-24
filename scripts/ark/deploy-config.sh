#!/usr/bin/env bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Deploys the sanitized ARK config while preserving the live passwords.

set -euo pipefail

[[ "$(cat /etc/hostname)" == "polyphonic-1" ]] || {
  echo "This script only runs on polyphonic-1." >&2
  exit 1
}

REPO="$HOME/repos/ark-server"
RENDERER="$REPO/scripts/render-config.py"
SAVED=/srv/ark-se/ShooterGame/Saved
LIVE="$SAVED/Config/LinuxServer"
UNIT=/etc/systemd/system/ark-server.service

[[ -x "$RENDERER" || -f "$RENDERER" ]] || {
  echo "Missing config renderer: $RENDERER" >&2
  exit 1
}
[[ -f "$LIVE/GameUserSettings.ini" && -f "$LIVE/Game.ini" ]] || {
  echo "Live GameUserSettings.ini and Game.ini must both exist." >&2
  exit 1
}
[[ -w "$LIVE/GameUserSettings.ini" && -w "$LIVE/Game.ini" ]] || {
  echo "Live config is not writable by $(id -un)." >&2
  exit 1
}
if grep -q 'SessionName=green-out-land' "$UNIT" ||
   ! grep -q '^ExecStartPre=/usr/bin/steamcmd ' "$UNIT" ||
   ! grep -q '^ExecStop=/usr/local/bin/ark-safe-stop' "$UNIT" ||
   ! grep -Fq 'TheIsland?listen?MaxPlayers=15 ' "$UNIT"; then
  echo "Install the updated unit first: sudo ~/scripts/ark/install-maintenance.sh" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
chmod 700 "$tmp"
python3 "$RENDERER" "$REPO/config" "$LIVE" "$tmp/rendered"

sudo -n /usr/bin/systemctl stop ark-server
if /usr/bin/systemctl is-active --quiet ark-server; then
  echo "ARK is still active after stop; config was not changed." >&2
  exit 1
fi
sudo -n /usr/bin/systemctl start ark-backup
sudo -n /usr/bin/systemctl reset-failed ark-server

cp "$LIVE/GameUserSettings.ini" "$tmp/previous-GameUserSettings.ini"
cp "$LIVE/Game.ini" "$tmp/previous-Game.ini"
if ! cat "$tmp/rendered/GameUserSettings.ini" >"$LIVE/GameUserSettings.ini" ||
   ! cat "$tmp/rendered/Game.ini" >"$LIVE/Game.ini"; then
  cat "$tmp/previous-GameUserSettings.ini" >"$LIVE/GameUserSettings.ini"
  cat "$tmp/previous-Game.ini" >"$LIVE/Game.ini"
  echo "Config write failed; previous files were restored." >&2
  exit 1
fi

# Admin list: these players can use cheat/admin commands in-game
if [[ -f "$REPO/config/AllowedCheaterSteamIDs.txt" ]]; then
  cat "$REPO/config/AllowedCheaterSteamIDs.txt" >"$SAVED/AllowedCheaterSteamIDs.txt"
fi

sudo -n /usr/bin/systemctl start ark-server
if ! /usr/bin/systemctl is-active --quiet ark-server; then
  echo "Config deployed, but ark-server did not become active; check journalctl." >&2
  exit 1
fi

echo "ARK config deployed and server is active. Passwords were preserved and not displayed."

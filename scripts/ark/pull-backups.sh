#!/usr/bin/env bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Run on the desktop (not the server): pulls the ARK backup archives over SSH.
# Skips quietly when the server is unreachable, so it is safe to run on a timer.
# Needs the desktop's SSH key in ben@polyphonic-1's authorized_keys.

set -uo pipefail

SERVER="${ARK_SERVER:-ben@192.168.1.146}"
DEST="${ARK_BACKUP_DEST:-$HOME/ark-backups}"
KEEP=30

mkdir -p "$DEST/daily" "$DEST/weekly"

if ! rsync -a --timeout=60 -e "ssh -o BatchMode=yes -o ConnectTimeout=5" \
  "$SERVER:/srv/ark-backups/" "$DEST/"; then
  echo "ARK server unreachable; will retry on the next run." >&2
  exit 0
fi

# The server only keeps 7 daily archives; keep a longer history here
for dir in daily weekly; do
  { ls -1t "$DEST/$dir"/ark-*.tar.zst 2>/dev/null || true; } |
    tail -n +"$((KEEP + 1))" | xargs -r rm --
done
echo "ARK backups synced to $DEST"

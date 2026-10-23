#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Backs up the ARK world saves and config (everything else can be
# re-downloaded with SteamCMD). Run by ark-backup.timer as the 'ark' user.
# Keeps 7 daily and 4 weekly archives. If ARK_BACKUP_RSYNC_TARGET is set
# (e.g. in /etc/default/ark-backup), copies the archives off this disk too.

set -euo pipefail

ARK_DIR="${ARK_DIR:-/srv/ark-se}"
BACKUP_DIR="${BACKUP_DIR:-/srv/ark-backups}"
SAVED="$ARK_DIR/ShooterGame/Saved"

mkdir -p "$BACKUP_DIR/daily" "$BACKUP_DIR/weekly"

stamp="$(date +%Y%m%d-%H%M%S)"
archive="$BACKUP_DIR/daily/ark-$stamp.tar.zst"

# Writing to a temp name so a failed run never leaves a partial archive
tar --zstd -cf "$archive.tmp" -C "$SAVED" SavedArks Config
mv "$archive.tmp" "$archive"

# Sunday's archive is also kept as the weekly one
if [[ "$(date +%u)" = "7" ]]; then
  cp "$archive" "$BACKUP_DIR/weekly/"
fi

prune() {
  local dir="$1" keep="$2"
  { ls -1t "$dir"/ark-*.tar.zst 2>/dev/null || true; } | tail -n +"$((keep + 1))" | xargs -r rm --
}
prune "$BACKUP_DIR/daily" 7
prune "$BACKUP_DIR/weekly" 4

if [[ -n "${ARK_BACKUP_RSYNC_TARGET:-}" ]]; then
  rsync -a --delete "$BACKUP_DIR/" "$ARK_BACKUP_RSYNC_TARGET"
fi

echo "Backup written: $archive"

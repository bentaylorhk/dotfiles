#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Backs up the ARK world saves and config (everything else can be
# re-downloaded with SteamCMD) and deletes server logs older than 14 days.
# Run by ark-backup.timer as the 'ark' user.
# Runs hourly. Keeps 48 hourly, 7 daily (the 04:00 run) and 4 weekly (Sunday's
# 04:00 run) archives. If ARK_BACKUP_RSYNC_TARGET is set
# (e.g. in /etc/default/ark-backup), copies the archives off this disk too.

set -euo pipefail

ARK_DIR="${ARK_DIR:-/srv/ark-se}"
BACKUP_DIR="${BACKUP_DIR:-/srv/ark-backups}"
SAVED="$ARK_DIR/ShooterGame/Saved"

mkdir -p "$BACKUP_DIR/hourly" "$BACKUP_DIR/daily" "$BACKUP_DIR/weekly"

stamp="$(date +%Y%m%d-%H%M%S)"
archive="$BACKUP_DIR/hourly/ark-$stamp.tar.zst"

# Writing to a temp name so a failed run never leaves a partial archive
tar --zstd -cf "$archive.tmp" -C "$SAVED" SavedArks Config
mv "$archive.tmp" "$archive"

# The first archive of the day (04:00 run) is also kept as the daily one,
# and Sunday's as the weekly one
if [[ "$(date +%H)" = "04" ]]; then
  cp "$archive" "$BACKUP_DIR/daily/"
  if [[ "$(date +%u)" = "7" ]]; then
    cp "$archive" "$BACKUP_DIR/weekly/"
  fi
fi

prune() {
  local dir="$1" keep="$2"
  { ls -1t "$dir"/ark-*.tar.zst 2>/dev/null || true; } | tail -n +"$((keep + 1))" | xargs -r rm --
}
prune "$BACKUP_DIR/hourly" 48
prune "$BACKUP_DIR/daily" 7
prune "$BACKUP_DIR/weekly" 4

# Old per-start server logs are only useful for a short while
find "$SAVED/Logs" -name 'ShooterGame-backup-*.log' -mtime +14 -delete

if [[ -n "${ARK_BACKUP_RSYNC_TARGET:-}" ]]; then
  rsync -a --delete "$BACKUP_DIR/" "$ARK_BACKUP_RSYNC_TARGET"
fi

echo "Backup written: $archive"

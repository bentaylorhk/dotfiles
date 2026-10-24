#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Installs the system-level files (outside $HOME) used by polyOS, backing up
# whatever they replace so the change can be rolled back.
# Services are only enabled with --enable.

set -euo pipefail

HOME_DIR="${HOME}"
BACKUP_ROOT="${POLYOS_BACKUP_DIR:-$HOME_DIR/.local/state/polyos/system-backups}"

# source (relative to $HOME)|destination|mode
MANIFEST=(
  "ascii-art/polyOS/caligraphy.txt|/usr/local/share/ascii-art/boot.txt|0644"
  "ascii-art/gecko.txt|/usr/local/share/ascii-art/login.txt|0644"
  "scripts/startup/formatted-issue|/usr/local/share/formatted-issue|0644"
  "scripts/startup/startup.sh|/usr/local/bin/startup.sh|0755"
  "scripts/startup/boot-animation|/usr/local/bin/boot-animation|0755"
  "scripts/justify.sh|/usr/local/bin/justify.sh|0755"
  "systemd/startup.service|/etc/systemd/system/startup.service|0644"
  "systemd/getty@tty1.service.d/override.conf|/etc/systemd/system/getty@tty1.service.d/override.conf|0644"
)
SERVICES=(startup.service getty@tty1.service)

DRY_RUN=0
ENABLE=0
ROLLBACK=0
ROLLBACK_ID=""

usage() {
  cat <<EOF
Usage: ${0##*/} [--dry-run] [--enable]
       ${0##*/} --rollback [timestamp]

  --dry-run          Show what would change without touching the system
  --enable           Also daemon-reload and enable the startup services
  --rollback [id]    Restore (or remove) files from a backup, newest by default
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

as_root() {
  if [[ "$EUID" -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

install_all() {
  local entry src dest mode stamp backup manifest changed=0
  stamp="$(date +%Y%m%d-%H%M%S)"
  backup="$BACKUP_ROOT/$stamp"
  manifest="$backup/manifest"

  for entry in "${MANIFEST[@]}"; do
    IFS='|' read -r src dest mode <<<"$entry"
    [[ -f "$HOME_DIR/$src" ]] || die "Missing source file $HOME_DIR/$src."

    if [[ -e "$dest" ]] && cmp -s "$HOME_DIR/$src" "$dest"; then
      echo "unchanged  $dest"
      continue
    fi
    changed=1

    if [[ "$DRY_RUN" -eq 1 ]]; then
      if [[ -e "$dest" ]]; then
        echo "update     $dest"
        diff -u "$dest" "$HOME_DIR/$src" || true
      else
        echo "create     $dest"
      fi
      continue
    fi

    mkdir -p "$backup"
    if [[ -e "$dest" ]]; then
      mkdir -p "$backup/files$(dirname "$dest")"
      as_root cp -p "$dest" "$backup/files$dest"
      echo "replace|$dest" >>"$manifest"
    else
      echo "create|$dest" >>"$manifest"
    fi
    as_root install -D -m "$mode" "$HOME_DIR/$src" "$dest"
    echo "installed  $dest"
  done

  if [[ "$changed" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
    echo "Backup saved in $backup"
  fi

  if [[ "$ENABLE" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] systemctl daemon-reload && systemctl enable ${SERVICES[*]}"
    else
      as_root systemctl daemon-reload
      as_root systemctl enable "${SERVICES[@]}"
    fi
  else
    echo "Services not enabled (use --enable)."
  fi
}

rollback() {
  local id="$ROLLBACK_ID" backup action dest
  if [[ -z "$id" ]]; then
    id="$(ls -1 "$BACKUP_ROOT" 2>/dev/null | sort | tail -n 1)"
  fi
  [[ -n "$id" && "$id" =~ ^[0-9]{8}-[0-9]{6}$ ]] || die "No valid backup found in $BACKUP_ROOT."
  backup="$BACKUP_ROOT/$id"
  [[ -f "$backup/manifest" ]] || die "No manifest for backup $id."

  while IFS='|' read -r action dest; do
    case "$action" in
      replace)
        echo "restore    $dest"
        [[ "$DRY_RUN" -eq 1 ]] || as_root install -D -m "$(stat -c %a "$backup/files$dest")" "$backup/files$dest" "$dest"
        ;;
      create)
        echo "remove     $dest"
        [[ "$DRY_RUN" -eq 1 ]] || as_root rm -f -- "$dest"
        ;;
    esac
  done <"$backup/manifest"
  [[ "$DRY_RUN" -eq 1 ]] || as_root systemctl daemon-reload
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --enable) ENABLE=1 ;;
    --rollback)
      ROLLBACK=1
      if [[ $# -ge 2 && "$2" != --* ]]; then
        ROLLBACK_ID="$2"
        shift
      fi
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "Unknown option '$1'."
      ;;
  esac
  shift
done

if [[ "$ROLLBACK" -eq 1 ]]; then rollback; else install_all; fi

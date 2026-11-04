#!/usr/bin/env bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Installs role-scoped systemd units from the shared polyOS host registry.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-systemd.sh [--role NAME]... [--dry-run]

Without --role, installs units for the current hostname's polyOS roles.
EOF
}

ROLE_NAMES=()
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --role)
      [[ $# -ge 2 ]] || { echo "Missing role name." >&2; exit 1; }
      ROLE_NAMES+=("$2")
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

[[ $EUID -eq 0 ]] || {
  echo "Run with sudo." >&2
  exit 1
}

USER_HOME=
if [[ -n "${SUDO_USER:-}" ]]; then
  USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
fi
[[ -n "$USER_HOME" ]] || {
  echo "Run this script through sudo from the polyOS user account." >&2
  exit 1
}

DOTFILES="$USER_HOME"
HOSTS_FILE="$DOTFILES/polyos/hosts.conf"
ROLE_DIR="$DOTFILES/systemd/roles"

if [[ ${#ROLE_NAMES[@]} -eq 0 ]]; then
  [[ -f "$HOSTS_FILE" ]] || {
    echo "Missing hostname registry: $HOSTS_FILE" >&2
    exit 1
  }

  hostname="$(cat /etc/hostname)"
  while IFS='=' read -r name roles; do
    [[ -n "$name" && "$name" != \#* ]] || continue
    if [[ "$name" == "$hostname" ]]; then
      IFS=',' read -r -a ROLE_NAMES <<<"$roles"
      break
    fi
  done <"$HOSTS_FILE"

  [[ ${#ROLE_NAMES[@]} -gt 0 ]] || {
    echo "No systemd roles are mapped for '$hostname'." >&2
    exit 0
  }
fi

declare -A SEEN_UNITS=()
declare -a UNIT_FILES=()
declare -a UNIT_NAMES=()
declare -a UNIT_ENABLES=()

for role in "${ROLE_NAMES[@]}"; do
  [[ "$role" =~ ^[a-z0-9][a-z0-9-]*$ ]] || {
    echo "Invalid role name: $role" >&2
    exit 1
  }

  requirements="$ROLE_DIR/$role.requires"
  if [[ -f "$requirements" ]]; then
    while IFS= read -r requirement; do
      requirement="${requirement#"${requirement%%[![:space:]]*}"}"
      requirement="${requirement%"${requirement##*[![:space:]]}"}"
      [[ -z "$requirement" || "$requirement" == \#* ]] && continue
      [[ -x "$requirement" ]] || {
        echo "Role '$role' requires executable '$requirement'." >&2
        exit 1
      }
    done <"$requirements"
  fi

  manifest="$ROLE_DIR/$role.conf"
  [[ -f "$manifest" ]] || continue

  while IFS='|' read -r source destination unit enable; do
    [[ -n "$source" && "$source" != \#* ]] || continue
    [[ -n "$destination" && -n "$unit" && -n "$enable" ]] || {
      echo "Invalid systemd manifest entry in $manifest." >&2
      exit 1
    }
    [[ "$source" != /* && "$source" != *".."* ]] || {
      echo "Unsafe source path in $manifest: $source" >&2
      exit 1
    }
    [[ "$destination" == /etc/systemd/system/* ]] || {
      echo "Unsafe destination path in $manifest: $destination" >&2
      exit 1
    }
    [[ "$enable" == enable || "$enable" == disable ]] || {
      echo "Invalid enable action in $manifest: $enable" >&2
      exit 1
    }
    [[ -f "$DOTFILES/$source" ]] || {
      echo "Missing source unit file: $DOTFILES/$source" >&2
      exit 1
    }
    [[ -n "${SEEN_UNITS[$destination]:-}" ]] && continue
    SEEN_UNITS["$destination"]=1
    UNIT_FILES+=("$source|$destination")
    UNIT_NAMES+=("$unit")
    UNIT_ENABLES+=("$enable")
  done <"$manifest"
done

if [[ ${#UNIT_FILES[@]} -eq 0 ]]; then
  echo "No systemd units are selected."
  exit 0
fi

for entry in "${UNIT_FILES[@]}"; do
  source="${entry%%|*}"
  destination="${entry#*|}"
  if "$DRY_RUN"; then
    echo "Would install $source to $destination"
  else
    install -Dm0644 "$DOTFILES/$source" "$destination"
  fi
done

if "$DRY_RUN"; then
  for index in "${!UNIT_NAMES[@]}"; do
    echo "Would ${UNIT_ENABLES[$index]} ${UNIT_NAMES[$index]}"
  done
  exit 0
fi

systemctl daemon-reload
for index in "${!UNIT_NAMES[@]}"; do
  systemd-analyze verify "${UNIT_NAMES[$index]}"
done
for index in "${!UNIT_NAMES[@]}"; do
  systemctl "${UNIT_ENABLES[$index]}" "${UNIT_NAMES[$index]}"
done

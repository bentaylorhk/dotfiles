#!/usr/bin/env bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Enables desktop networking and applies host-approved SSH hardening.

set -euo pipefail

DRY_RUN=false

usage() {
  echo "Usage: install-network.sh [--dry-run]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
  shift
done

repo_dir="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
ROLES=""
SSH_SERVER="no"
POLYOS_HOSTS_DIR="$repo_dir/hosts"
export POLYOS_HOSTS_DIR
# shellcheck disable=SC1091
. "$repo_dir/scripts/lib/host.sh"

has_role() {
  local role="$1" selected
  for selected in $ROLES; do
    [[ "$selected" == "$role" ]] && return 0
  done
  return 1
}

as_root() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

if has_role desktop; then
  if "$DRY_RUN"; then
    echo "Would enable NetworkManager.service"
  else
    as_root systemctl enable NetworkManager.service
  fi
fi

[[ "$SSH_SERVER" == "yes" ]] || exit 0

user_name="${SUDO_USER:-$USER}"
user_home="$(getent passwd "$user_name" | cut -d: -f6)"
[[ -n "$user_home" ]] || {
  echo "Could not find the home directory for $user_name." >&2
  exit 1
}

authorized_keys="$user_home/.ssh/authorized_keys"
[[ -s "$authorized_keys" ]] || {
  echo "Refusing SSH hardening without $authorized_keys." >&2
  exit 1
}

source_file="$repo_dir/system/ssh/10-hardening.conf"
destination=/etc/ssh/sshd_config.d/10-hardening.conf
[[ -f "$source_file" ]] || {
  echo "Missing SSH hardening source: $source_file" >&2
  exit 1
}

if "$DRY_RUN"; then
  echo "Would install $source_file to $destination"
  echo "Would enable and reload sshd.service"
  exit 0
fi

as_root chmod 700 "$user_home/.ssh"
as_root chmod 600 "$authorized_keys"
as_root chown "$user_name":"$(id -gn "$user_name")" "$user_home/.ssh" "$authorized_keys"

backup=
if [[ -e "$destination" ]]; then
  backup="$(mktemp)"
  as_root cp --preserve=mode "$destination" "$backup"
fi

as_root install -Dm0644 "$source_file" "$destination"
if ! as_root sshd -t; then
  if [[ -n "$backup" ]]; then
    as_root install -Dm0644 "$backup" "$destination"
    rm -f "$backup"
  else
    as_root rm -f "$destination"
  fi
  echo "SSH configuration validation failed; previous configuration was restored." >&2
  exit 1
fi
[[ -z "$backup" ]] || rm -f "$backup"

as_root systemctl enable --now sshd.service
as_root systemctl reload sshd.service

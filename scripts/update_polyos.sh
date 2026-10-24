#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025-2026

# Script used to sync polyOS between machines: dotfiles, pacman packages
# and AUR packages. Run it as your normal user, it uses sudo only for pacman
# and system files. Package roles come from hosts/<hostname>.conf.

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
REPO_DIR="$(dirname "$(dirname "$SCRIPT_PATH")")"
GIT_DIR="${DOTFILES_GIT_DIR:-$REPO_DIR/.dotfiles}"
PACKAGES_DIR="$REPO_DIR/packages"

DRY_RUN=0
ASSUME_YES=0
ROLES_OVERRIDE=""

usage() {
  cat <<EOF
Usage: ${0##*/} <command> [options]

Commands:
  sync           Pull the latest dotfiles (fast-forward only)
  packages       Install missing pacman packages for this host's roles
  aur            Install missing AUR packages with yay (skipped without yay)
  system-config  Install system-level files, see scripts/install-system.sh
  upgrade        Run a full system upgrade (pacman -Syu)
  all            sync, upgrade, packages, then aur

Options:
  --roles a,b    Use these package roles instead of the host's roles
  --dry-run      Print what would happen without changing anything
  --yes          Don't ask pacman or yay for confirmation
  -h, --help     Show this help
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

# Prints the command in a dry run, otherwise runs it
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

run_root() {
  if [[ "$EUID" -eq 0 ]]; then
    run "$@"
  else
    run sudo "$@"
  fi
}

# Prints the packages in a role file, ignoring comments and blank lines
read_role() {
  local role="$1" file line
  [[ "$role" =~ ^[a-z0-9_-]+$ ]] || die "Invalid role name '$role'."
  file="$PACKAGES_DIR/$role.txt"
  [[ -f "$file" ]] || die "No package list for role '$role' ($file)."
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -n "$line" ]] && echo "$line"
  done <"$file"
  return 0
}

host_roles() {
  if [[ -n "$ROLES_OVERRIDE" ]]; then
    echo "${ROLES_OVERRIDE//,/ }"
    return
  fi
  local ROLES=""
  # shellcheck disable=SC1091
  [[ -f "$REPO_DIR/scripts/lib/host.sh" ]] &&
    POLYOS_HOSTS_DIR="$REPO_DIR/hosts" . "$REPO_DIR/scripts/lib/host.sh"
  echo "$ROLES"
}

cmd_sync() {
  echo "Syncing dotfiles"
  run git --git-dir="$GIT_DIR" --work-tree="$REPO_DIR" pull --ff-only
}

cmd_upgrade() {
  echo "Upgrading system..."
  local args=(-Syu)
  [[ "$ASSUME_YES" -eq 1 ]] && args+=(--noconfirm)
  run_root pacman "${args[@]}"
}

cmd_packages() {
  local roles role packages=() args=(-S --needed)
  roles="$(host_roles)"
  [[ -n "$roles" ]] || die "No package roles found, set ROLES in hosts/default.conf."
  echo "Installing packages for roles: $roles"
  for role in $roles; do
    [[ "$role" == aur ]] && die "The 'aur' role is installed with the aur command."
    mapfile -t -O "${#packages[@]}" packages < <(read_role "$role")
  done
  [[ "${#packages[@]}" -gt 0 ]] || die "The selected roles contain no packages."
  [[ "$ASSUME_YES" -eq 1 ]] && args+=(--noconfirm)
  run_root pacman "${args[@]}" "${packages[@]}"
}

cmd_aur() {
  local packages=() args=(-S --needed)
  if ! command -v yay >/dev/null 2>&1; then
    echo "yay is not installed, skipping AUR packages (see packages/aur.txt)."
    return 0
  fi
  [[ "$EUID" -ne 0 ]] || die "yay must not run as root."
  mapfile -t packages < <(read_role aur)
  [[ "${#packages[@]}" -gt 0 ]] || return 0
  echo "Installing AUR packages..."
  [[ "$ASSUME_YES" -eq 1 ]] && args+=(--noconfirm)
  run yay "${args[@]}" "${packages[@]}"
}

cmd_system_config() {
  local args=()
  [[ "$DRY_RUN" -eq 1 ]] && args+=(--dry-run)
  "$REPO_DIR/scripts/install-system.sh" "${args[@]}"
}

# Runs every step even if one fails, and returns the first failing status
cmd_all() {
  local status=0 step
  for step in cmd_sync cmd_upgrade cmd_packages cmd_aur; do
    "$step" || {
      local rc=$?
      echo "${step#cmd_} failed." >&2
      [[ "$status" -eq 0 ]] && status=$rc
    }
  done
  return "$status"
}

main() {
  [[ $# -gt 0 ]] || {
    usage
    return 1
  }
  [[ "$EUID" -ne 0 ]] || die "Run as your normal user, sudo is used when needed."

  local command="$1"
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --yes) ASSUME_YES=1 ;;
      --roles)
        [[ $# -ge 2 ]] || die "--roles needs a value."
        ROLES_OVERRIDE="$2"
        shift
        ;;
      -h | --help)
        usage
        return 0
        ;;
      *) die "Unknown option '$1'." ;;
    esac
    shift
  done

  local status=0
  case "$command" in
    sync) cmd_sync || status=$? ;;
    packages) cmd_packages || status=$? ;;
    aur) cmd_aur || status=$? ;;
    system-config) cmd_system_config || status=$? ;;
    upgrade) cmd_upgrade || status=$? ;;
    all) cmd_all || status=$? ;;
    -h | --help)
      usage
      return 0
      ;;
    *)
      usage >&2
      die "Unknown command '$command'."
      ;;
  esac

  echo ""
  if [[ "$status" -eq 0 ]]; then
    echo "$command completed successfully."
  else
    echo "$command failed." >&2
  fi

  # Keeps the floating update window open until it has been read
  if [[ "$DRY_RUN" -eq 0 && "$ASSUME_YES" -eq 0 && -t 0 && -t 1 ]]; then
    read -r -p $'Press Enter to continue...' || true
  fi
  return "$status"
}

# On one line so bash never re-reads this file if 'sync' replaces it
main "$@"; exit $?

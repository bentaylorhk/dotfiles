#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

# Script used to sync polyOS between machines. Syncs
# its dotfiles, and pacman packages.

# To get this script to run without a sudo prompt, add the
# following line to sudoers with 'sudo visudo'
# <username> ALL=(ALL) NOPASSWD: /path/to/update_polyos.sh

set -e

if [[ $EUID -ne 0 ]]; then
  # Sync dotfiles before pacman to update packages file
  echo "Syncing dotfiles"
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" pull

  # Using user home if list not provided
  PACKAGE_FILE="${1:-$HOME/pkglist.txt}"
  PACKAGE_FILE="$(realpath -e -- "$PACKAGE_FILE")"

  echo "Promoting to root privileges..."

  # Running whole script as root, then exiting
  exec sudo bash "$0" "$PACKAGE_FILE"
fi

if [[ -n "${1:-}" ]]; then
  PACKAGE_FILE="$1"
elif [[ -n "${SUDO_USER:-}" ]]; then
  USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  if [[ -z "$USER_HOME" ]]; then
    echo "Could not find the home directory for $SUDO_USER." >&2
    exit 1
  fi
  PACKAGE_FILE="$USER_HOME/pkglist.txt"
else
  PACKAGE_FILE="$HOME/pkglist.txt"
fi

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Error: Package list file '$PACKAGE_FILE' not found."
  exit 1
fi

# System update
echo "Updating system..."
if ! pacman -Syuu --noconfirm; then
  echo "System update failed." >&2
  exit 1
fi

# Read package list, ignoring comments (#) and empty lines
echo "Reading package list from '$PACKAGE_FILE'..."
PACKAGES=()
while IFS= read -r line; do
  line="${line%%#*}" # Remove comments
  line="${line// /}" # Remove spaces
  if [[ -n "$line" ]]; then
    PACKAGES+=("$line")
  fi
done <"$PACKAGE_FILE"

echo "Installing user packages..."
install_status=0
if pacman -S --needed --noconfirm "${PACKAGES[@]}"; then
  :
else
  install_status=$?
  echo "Package installation failed." >&2
fi

# TODO: Ensure polyai is installed with pip

if [[ "$install_status" -eq 0 ]]; then
  echo ""
  echo "Update and package installation completed successfully."
else
  echo ""
  echo "Update or package installation failed."
fi

if [[ -t 0 ]]; then
  read -r -p $'Press Enter to continue...' || true
fi

exit "$install_status"

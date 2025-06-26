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
  git --git-dir=$HOME/.dotfiles --work-tree=$HOME pull

  # Using user home if list not provided
  PACKAGE_FILE="${1:-$HOME/pkglist.txt}"

  echo "Promoting to root privileges..."

  # Running whole script as root, then exiting
  exec sudo bash "$0" "$PACKAGE_FILE"
fi

# Check if running as root after sudo promotion
if [[ $EUID -ne 0 ]]; then
  echo "Failed to obtain root privileges. Exiting."
  exit 1
fi

# Check if package list is provided
if [[ -z "$1" ]]; then
  echo "Usage: $0 <packages.txt>"
  echo "    '~/pkglist.txt' used by default"
  exit 1
fi

PACKAGE_FILE="$1"

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Error: Package list file '$PACKAGE_FILE' not found."
  exit 1
fi

# System update
echo "Updating system..."
pacman -Syuu --noconfirm

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

set +e
echo "Installing user packages..."
pacman -S --needed --noconfirm "${PACKAGES[@]}"

# TODO: Ensure polyai is installed with pip

# Print success or failure message and wait for user input
if [[ $? -eq 0 ]]; then
  echo ""
  echo "Update and package installation completed successfully."
else
  echo ""
  echo "Update or package installation failed."
fi

read -p $'Press Enter to continue...'

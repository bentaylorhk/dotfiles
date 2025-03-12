#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

set -e

if [[ $EUID -ne 0 ]]; then
  # Using user home if list not provided
  PACKAGE_FILE="${1:-$HOME/packages.txt}"

  echo "Promoting to root privileges"

  # Running whole script as root, then exiting
  exec sudo bash "$0" "PACKAGE_FILE"
fi

# Check if package list is provided
if [[ -z "$1" ]]; then
  echo "Usage: $0 <packages.txt>"
  echo "    '~/packages.txt' used by default"
  exit 1
fi

PACKAGE_FILE="$1"

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Error: Package list file '$PACKAGE_FILE' not found."
  exit 1
fi

echo "Syncing dotfiles"
dotfiles pull

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

echo "Installing user packages..."
pacman -S --needed --noconfirm "${PACKAGES[@]}"

# TODO: Ensure polyai is installed with pip

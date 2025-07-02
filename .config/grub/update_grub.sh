#!/bin/sh

# Benjamin Michael Taylor (bentaylorhk)
# 2023 - 2025

set -e

FONT_NAME="scientifica"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo." >&2
    echo "Usage: sudo $0" >&2
    exit 1
fi

FONT_FILE="$SCRIPT_DIR/theme/$FONT_NAME.pf2"
"$SCRIPT_DIR/make_font.sh" "$FONT_NAME"

DEFAULT_PATH="/etc/default/grub"
echo "Copying GRUB default configuration to $DEFAULT_PATH..."
cp $SCRIPT_DIR/default "$DEFAULT_PATH"

THEME_DIR="/boot/grub/themes/polyos"
echo "Copying theme to $THEME_DIR"
mkdir -p $THEME_DIR
cp -r $SCRIPT_DIR/theme/* $THEME_DIR/.

echo "Searching for Windows partition using os-prober..."
WINDOWS_ENTRY=$(os-prober 2>/dev/null | grep -i "windows" | head -n1 || true)

if [ -n "$WINDOWS_ENTRY" ]; then
    # Extract partition from os-prober output 
    # (format: /dev/nvmeXnYpZ@/efi/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi)
    WINDOWS_PARTITION=$(echo "$WINDOWS_ENTRY" | cut -d'@' -f1)
    
    if [ -b "$WINDOWS_PARTITION" ]; then
        echo "Found Windows partition: $WINDOWS_PARTITION"
        echo "Mounting Windows EFI partition $WINDOWS_PARTITION to /windows"
        mkdir -p /windows
        mount "$WINDOWS_PARTITION" /windows
        echo "Successfully mounted $WINDOWS_PARTITION to /windows"
    else
        echo "Error: Windows partition $WINDOWS_PARTITION is not a valid block device. Exiting." >&2
        exit 1
    fi
else
    echo "Error: Could not find Windows partition using os-prober. Exiting." >&2
    exit 1
fi

grub-mkconfig -o /boot/grub/grub.cfg

echo "Unmounting /windows"
umount /windows

#! /bin/sh

# Benjamin Michael Taylor (bentaylorhk)
# 2023 - 2025

set -e

# Check if running as root/sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo." >&2
    echo "Usage: sudo $0" >&2
    exit 1
fi

# Find Windows partition using os-prober
echo "Searching for Windows partition using os-prober..."
WINDOWS_ENTRY=$(os-prober 2>/dev/null | grep -i "windows" | head -n1 || true)

if [ -n "$WINDOWS_ENTRY" ]; then
    # Extract partition from os-prober output (format: /dev/nvmeXnYpZ@/efi/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi)
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

# Generate GRUB configuration
echo "Generating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg
echo "GRUB configuration updated successfully!"

# Unmount the Windows partition
echo "Unmounting /windows"
umount /windows

#! /bin/sh
# Benjamin Michael Taylor (bentaylorhk)
# 2023 - 2025
set -e

# TODO: set Divide script up by hostname

mount /dev/nvme0n1p1 /windows
grub-mkconfig -o /boot/grub/grub.cfg

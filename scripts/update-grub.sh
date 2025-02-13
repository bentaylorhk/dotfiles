#! /bin/sh
# Benjamin Michael Taylor (bentaylorhk)
# 2023 - 2024
set -e

mount /dev/nvme0n1p1 /windows
grub-mkconfig -o /boot/grub/grub.cfg

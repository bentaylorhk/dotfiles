#!/bin/sh
# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Source this file to load hosts/default.conf, then hosts/<hostname>.conf.
# POLYOS_HOSTNAME and POLYOS_HOSTS_DIR can be set to override detection.

POLYOS_HOSTNAME="${POLYOS_HOSTNAME:-$(cat /etc/hostname 2>/dev/null || true)}"
POLYOS_HOSTS_DIR="${POLYOS_HOSTS_DIR:-$HOME/hosts}"

if [ -f "$POLYOS_HOSTS_DIR/default.conf" ]; then
  # shellcheck disable=SC1091
  . "$POLYOS_HOSTS_DIR/default.conf"
fi

# Hostnames are only used as file names, so refuse anything with a path in it
case "$POLYOS_HOSTNAME" in
  '' | */* | .*) ;;
  *)
    if [ -f "$POLYOS_HOSTS_DIR/$POLYOS_HOSTNAME.conf" ]; then
      # shellcheck disable=SC1090
      . "$POLYOS_HOSTS_DIR/$POLYOS_HOSTNAME.conf"
    fi
    ;;
esac

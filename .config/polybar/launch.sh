#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

set -euo pipefail

pkill -u "$UID" -x polybar 2>/dev/null || true

for _ in {1..50}; do
  if ! pgrep -u "$UID" -x polybar >/dev/null; then
    break
  fi
  sleep 0.1
done

if pgrep -u "$UID" -x polybar >/dev/null; then
  echo "Timed out waiting for the current Polybar processes to exit." >&2
  exit 1
fi

while IFS= read -r monitor; do
  [ -n "$monitor" ] || continue
  if [ "$monitor" = "DVI-0" ]; then
    MONITOR="$monitor" polybar crt &
  else
    MONITOR="$monitor" polybar main &
  fi
done < <(polybar --list-monitors | cut -d: -f1)

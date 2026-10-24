#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Run by ark-server.service as ExecStop: saves the world, then asks ARK to
# exit cleanly over local RCON. If RCON is unavailable it exits quietly and
# systemd falls back to the normal SIGINT stop.
# Installed as /usr/local/bin/ark-safe-stop.

set -uo pipefail

/usr/local/bin/ark-rcon --timeout 90 saveworld || exit 0
/usr/local/bin/ark-rcon --timeout 10 doexit || true

# Give ARK time to finish exiting before systemd sends its own signal
for _ in $(seq 1 60); do
  kill -0 "${MAINPID:-0}" 2>/dev/null || exit 0
  sleep 1
done

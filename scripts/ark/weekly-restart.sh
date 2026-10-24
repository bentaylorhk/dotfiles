#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Started by ark-restart.timer at 10:30 on Mondays: warns players at one hour,
# 30 minutes and 5 minutes, then restarts ARK at 11:30 (which also picks up
# game updates). The stop is a clean save via ark-safe-stop.
# Installed as /usr/local/bin/ark-weekly-restart.

set -euo pipefail

say() {
  /usr/local/bin/ark-rcon "serverchat $1" || echo "Could not send warning: $1" >&2
}

systemctl is-active --quiet ark-server.service || exit 0

say "Weekly restart in 1 hour (11:30). Time to green out."
sleep 1800
say "Weekly restart in 30 minutes."
sleep 1500
say "Weekly restart in 5 minutes. Finish up and get somewhere safe."
sleep 300

systemctl restart ark-server.service

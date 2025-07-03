#!/bin/bash 

# Benjamin Michael Taylor (bentaylorhk)
# 2025

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 0.01; done

for m in $(polybar --list-monitors | cut -d: -f1); do
  if [ "$m" = "DVI-0" ]; then
      MONITOR=$m polybar crt &
  else
      MONITOR=$m polybar main &
  fi
done

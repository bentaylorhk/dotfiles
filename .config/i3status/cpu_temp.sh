#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

set -e

HOST=$(hostname)
case "$HOST" in
    gpd-pocket-3-polyos)
        TEMP_PATH="/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp1_input"
        ;;
    polyphonic-1)
        TEMP_PATH="/sys/class/hwmon/hwmon0/temp1_input"
        ;;
    atx-polyos)
        TEMP_PATH="/sys/class/hwmon/hwmon4/temp1_input"
        ;;
    *)
        TEMP_PATH=""
        ;;
esac

if [ -n "$TEMP_PATH" ] && [ -f "$TEMP_PATH" ]; then
    TEMP=$(cat "$TEMP_PATH")
    TEMP_C=$((TEMP / 1000))
    printf "CPU: %s°C" "$TEMP_C\n"

else
    printf "CPU: N/A\n"
fi

exit 0

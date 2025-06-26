#!/bin/bash

# Benjamin Michael Taylor
# 2025

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SCREENSAVER="$SCRIPT_DIR/screensaver_wrapper.sh"

TITLE="Screensaver-$RANDOM"

alacritty --title "$TITLE" --class Screensaver -e $SCREENSAVER &
ALACRITTY_PID=$!

sleep 0.5

i3-msg "[title=\"$TITLE\"] fullscreen enable"

wait $ALACRITTY_PID


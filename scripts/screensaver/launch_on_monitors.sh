#!/bin/bash

# Benjamin Michael Taylor
# 2025

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SCREENSAVER="$SCRIPT_DIR/screensaver_wrapper.sh"

# Get the visible workspace for each output
mapfile -t WORKSPACE_MAP < <(i3-msg -t get_workspaces | jq -r '.[] | select(.visible) | "\(.output):\(.name)"')

for ENTRY in "${WORKSPACE_MAP[@]}"; do
  MON="${ENTRY%%:*}"
  WS="${ENTRY#*:}"
  TITLE="Autolock-$MON"

  if [ "$MON" = "DVI-0" ]; then
    FONT_OPT="--option font.size=6"
  else
    FONT_OPT=""
  fi

  alacritty $FONT_OPT \
    --title "$TITLE" \
    --command "$SCREENSAVER" &

  sleep 0.5

  # Move to the current workspace for this output, then fullscreen
  i3-msg "[title=\"$TITLE\"] move to workspace \"$WS\""
  i3-msg "[title=\"$TITLE\"] fullscreen enable"
done

exit 0

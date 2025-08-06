#!/bin/bash

# Benjamin Michael Taylor
# 2025

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SCREENSAVER="$SCRIPT_DIR/screensaver_wrapper.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -window-id) WINID="$2"; shift 2 ;;
    *) shift ;;
  esac
done

xterm -fa 'scientifica' -fs 13 -into "$WINID" -e env TERM=xterm-256color -e $SCREENSAVER

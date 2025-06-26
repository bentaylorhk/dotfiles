#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

# Launch Alacritty with a unique title so we can find it
alacritty --title "update-polyos" -e 'update_polyos.sh' &

# Give it a moment to appear
sleep 0.1

# Make it floating and center it
i3-msg '[title="update-polyos"] floating enable, move position center, border pixel 5'
